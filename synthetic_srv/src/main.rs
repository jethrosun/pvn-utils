extern crate failure;
extern crate rand;
extern crate resize;
extern crate serde_json;
extern crate y4m;

use crate::transcode::*;
use crate::udf::*;
use core_affinity::CoreId;
use std::convert::TryInto;
use std::fs::File;
use std::io::Read;
use std::time::Instant;
use std::{env, process, vec};
use tokio::time;
use std::collections::HashMap;

mod transcode;
mod udf;

/// Generate the job queue to be executed.
///
/// Specifically, we put all jobs that are behind into the first to execute
fn create_job_queue(
    executed: &usize,
    cur_time: usize,
    workload: &HashMap<usize, u64>,
    counts: &mut Vec<u64>,
    timestamps: &mut Vec<usize>,
) {
    println!("\tDEBUG: executed: {:?}, cur time {:?} ", executed, cur_time );
    timestamps.push(*executed);
    timestamps.push(cur_time);
    let values = (*executed..cur_time+1).map(|x| *workload.get(&x).unwrap()).collect::<Vec<_>>();
    counts.push(values.iter().sum());

    // let mut values = Vec::new();
    // for i in *executed..cur_time+1 {
    //     values.push(*workload.get(&i).unwrap());
    // }
    // counts.push(values.iter().sum());

    for i in cur_time + 1..cur_time +5{
        let work_at_i = workload.get(&i).unwrap();
        println!("\tDEBUG workload at {} is {}", i, work_at_i);
        counts.push(*work_at_i);
        timestamps.push(i);
    }
    println!("DEBUG_job_queue: timestamps {:?}, counts {:?}", timestamps, counts);
}


/// key property: the workload is sorted by deadline, and we need to guarantee that the job will be exeuted eventually
async fn enforce_process_xcdr(
    interval: &mut time::Interval,
    counts: &mut Vec<u64>,
    buffer: &mut Vec<u8>,
    width_height: &str,
    loads: &mut Vec<usize>,
    lats: &mut Vec<u128>,
) {
    for count in counts {
        interval.tick().await;
        let elapsed = transcode_jobs(*count, buffer.as_slice(), width_height).unwrap();
        loads.push(*count as usize);
        lats.push(elapsed.as_millis());
    }
}

async fn enforce_process_rand(
    pname: &str,
    interval: &mut time::Interval,
    counts: &mut Vec<u64>,
    cname: &String,
    large_vec: &Vec<u128>,
    buf: &mut Box<[u8]>,
    loads: &mut Vec<usize>,
    lats: &mut Vec<u128>,
) {
    for count in counts {
        interval.tick().await;
        let load = udf_load(&pname, *count as f64).unwrap();
        let elapsed = execute(load, cname, &large_vec, buf).unwrap();
        loads.push(*count as usize);
        lats.push(elapsed.as_millis());
    }
}

async fn process_xcdr(
    interval: &mut time::Interval,
    count: u64,
    buffer: &mut Vec<u8>,
    width_height: &str,
    loads: &mut Vec<usize>,
    lats: &mut Vec<u128>,
) {
    for _i in 0..5 {
        interval.tick().await;
        let elapsed = transcode_jobs(count, buffer.as_slice(), width_height).unwrap();
        loads.push(count as usize);
        lats.push(elapsed.as_millis());
    }
}

async fn process_rand(
    interval: &mut time::Interval,
    count: u64,
    load: Load,
    cname: &String,
    large_vec: &Vec<u128>,
    buf: &mut Box<[u8]>,
    loads: &mut Vec<usize>,
    lats: &mut Vec<u128>,
) {
    for _ in 0..5 {
        interval.tick().await;
        let elapsed = execute(load, cname, &large_vec, buf).unwrap();
        loads.push(count as usize);
        lats.push(elapsed.as_millis());
    }
}

#[tokio::main]
async fn main() {
    let expr_time = 4000;

    let params: Vec<String> = env::args().collect();
    if params.len() == 5 {
        println!("Parsing 4 args");
        println!("{:?}", params);
    } else {
        println!("More or less than 4 args are provided. Run it with *profile_id/name node_id core_id enforce*");
        process::exit(0x0100);
    }

    let profile_id = params[1].parse::<usize>().unwrap();
    let node_id = params[2].parse::<usize>().unwrap();
    let core_id = params[3].parse::<usize>().unwrap();
    let enforce = match params[4].parse::<usize>(){
        Ok(1) => true,  // we are enforcing all jobs to be explicitly executed, even passed its
                        // deadline
        Ok(0) => false, // jobs will not be scheduled if passed deadline
        Ok(_) => {
            println!("Neither 1 or 0 are passed as enforce value, exiting...");
            process::exit(0x0100);
        },
        Err(e) => {
            println!("Parse Error: {:?}, exiting...", e);
            process::exit(0x0100);
        },
    } ;
    let core = CoreId { id: core_id };

    // get udf profiles
    // let profile_map_path = "/home/jethros/dev/pvn/workload/udf_config/profile_map.json";
    let profile_map_path = "/udf_config/profile_map.json";

    let profile_map = map_profile(profile_map_path.to_string()).unwrap();
    let profile_name = profile_map.get(&profile_id).unwrap().clone();
    println!(
        "node id {}, core id {}, profile id {} // name {:?}",
        node_id, core_id, profile_id, profile_name
    );

    // get workload based on node_id/core_id/profile_id
    // let workload_path = "/home/jethros/dev/pvn/workload/udf_workload/contention/udf_profile"
    //     .to_owned()
    //     + &profile_id.to_string()
    //     + "_node"
    //     + &node_id.to_string()
    //     + "_core"
    //     + &core_id.to_string()
    //     + ".json";
    let workload_path = "/udf_workload/udf_profile".to_owned()
        + &profile_id.to_string()
        + "_node"
        + &node_id.to_string()
        + "_core"
        + &core_id.to_string()
        + ".json";

    let (times, workload) = if enforce {
        retrieve_enforce_workload(workload_path.to_string(), expr_time).unwrap()
    }
    else {
        retrieve_workload(workload_path.to_string(), expr_time).unwrap()
    };

    println!("retrieved workload: {}", workload_path);
    println!("times {:?}", times);
    println!("edf_workload {:?}", workload);

    let cname = core_id.to_string() + "-" + &profile_id.to_string();
    let pname = profile_name.clone();

    let mut beginning = Instant::now();

    // states for non enforce version
    let mut count = if times.contains(&0) {
        *workload.get(&0).unwrap()
    } else {
        0 as u64
    };
    let mut times_iter = times.iter();
    let mut pivot = times_iter.next().unwrap();
    match times_iter.next() {
        Some(p) => pivot = p,
        None => pivot = &4000,
    }
    println!(
        "WorkloadChanged, count: {:?} waiting for: {:?}",
        count, pivot,
    );
    // states for enforce version
    let mut executed = 0;

    let mut loads = Vec::new();
    let mut lats = Vec::new();
    let mut counts = Vec::new();
    let mut timestamps = Vec::new();

    if pname == "xcdr" {
        // let infile = "/home/jethros/dev/pvn/utils/data/tiny.y4m";
        // let infile = "/Users/jethros/dev/pvn/utils/data/tiny.y4m";
        let infile = "/udf_data/tiny.y4m";
        let width_height = "360x24";

        let mut file = File::open(infile).unwrap();
        let mut buffer = Vec::new();
        file.read_to_end(&mut buffer).unwrap();

        println!("Timer started after {:?}", beginning.elapsed().as_millis());
        beginning = Instant::now();

        let mut interval = time::interval(time::Duration::from_secs(1));
        loop {
            let cur_time = Instant::now();
            loads.clear();
            lats.clear();
            counts.clear();
            timestamps.clear();

            if enforce {
                create_job_queue(&mut executed, beginning.elapsed().as_secs() as usize, &workload, &mut counts, &mut timestamps);
                enforce_process_xcdr(
                    &mut interval,
                    &mut counts,
                    &mut buffer,
                    width_height,
                    &mut loads,
                    &mut lats,
                ).await;
            }
            else {
                process_xcdr(
                    &mut interval,
                    count,
                    &mut buffer,
                    width_height,
                    &mut loads,
                    &mut lats,
                ).await;
            }
            println!(
                "Info: {:?} users in {:?}ms with core: {:?}",
                count * 5,
                cur_time.elapsed().as_millis(),
                core
            );

            let report_time = beginning.elapsed().as_secs();
            println!("Metric: {:?} {:?} {:?}", report_time, loads, lats);
            // println!("Latency(ms): {:?} {:?}", report_time, lats);

            // run until the next change
            if report_time >= expr_time as u64 {
                println!("Have run for {}, exiting now", expr_time);
                process::exit(0x0100);
            } else if report_time >= *pivot as u64 && !enforce {
                count = *workload.get(pivot).unwrap();
                pivot = match times_iter.next() {
                    Some(t) => t,
                    None => &expr_time,
                };
                // num_of_jobs = (((count / 10) as f64 + 0.01).ceil() * 1.13).ceil() as usize;
                println!(
                    "WorkloadChanged, count: {:?} pivot waiting for: {:?}",
                    count, pivot
                );
                continue;
            }
        }
    }
    // rand1-4
    else {
        // max size
        let max_count = workload.iter().max_by_key(|entry| entry.1).unwrap();
        let max_load = udf_load(&pname, *max_count.1 as f64).unwrap();

        // actual load
        let mut load = udf_load(&pname, count as f64).unwrap();
        println!("WorkloadChanged, count: {:?} load: {:?}", count, load);

        // RAM
        // let mut large_vec = vec![42u128; (load.ram as u128).try_into().unwrap()];
        // 1MB = 62500 * 16 Byte (unit)
        let mut large_vec = vec![42u128; (max_load.ram * 62_500).try_into().unwrap()];

        // File I/O: use buffer to store random data
        // 1 MB = 1_000_000 * 1 Byte (unit)
        let mut buf: Vec<u8> = Vec::with_capacity((load.io * 1_000_000).try_into().unwrap()); // B to MB
        for _ in 0..buf.capacity() {
            buf.push(rand::random())
        }
        println!("buf size: {:?}", buf.capacity());
        let mut buf = buf.into_boxed_slice();

        beginning = Instant::now();
        let mut interval = time::interval(time::Duration::from_secs(1));
        loop {
            loads.clear();
            lats.clear();
            counts.clear();
            timestamps.clear();

            let cur_time = Instant::now();
            if enforce {
                create_job_queue(&mut executed, beginning.elapsed().as_secs() as usize, &workload, &mut counts, &mut timestamps);
                enforce_process_rand(
                    &pname,
                    &mut interval,
                    &mut counts,
                    &cname,
                    &large_vec,
                    &mut buf,
                    &mut loads,
                    &mut lats,
                ).await;
            }
            else {
                process_rand(
                    &mut interval,
                    count,
                    load,
                    &cname,
                    &large_vec,
                    &mut buf,
                    &mut loads,
                    &mut lats,
                ).await;
            }

            println!(
                "Info: count {:?} in {:?}ms with core: {:?}",
                count * 5,
                cur_time.elapsed().as_millis(),
                core
            );
            let report_time = beginning.elapsed().as_secs();
            println!("Metric: {:?} {:?} {:?}", report_time, loads, lats);
            // println!("Latency(ms): {:?} {:?}", report_time, lats);

            // run until the next change
            if report_time >= expr_time as u64 {
                println!("Have run for {}, exiting now", expr_time);
                process::exit(0x0100);
            } else if report_time >= *pivot as u64 && !enforce {
                count = *workload.get(pivot).unwrap();
                pivot = match times_iter.next() {
                    Some(t) => t,
                    None => &expr_time,
                };
                load = udf_load(&pname, count as f64).unwrap();
                println!(
                    "WorkloadChanged, count: {:?} pivot waiting for: {:?}, new load {:?}",
                    count, pivot, load
                );
                large_vec.resize(load.ram as usize, 42u128);
                continue;
            } else {
                // let elapsed = cur_time.elapsed();
                // if elapsed < Duration::from_millis(4990) {
                //     thread::sleep(Duration::from_millis(4990) - elapsed);
                // }
            }
        }
    }
}
