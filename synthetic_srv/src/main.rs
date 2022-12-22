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

mod transcode;
mod udf;

async fn process_xcdr(
    interval: &mut time::Interval,
    count: u64,
    num_of_jobs: usize,
    buffer: &mut Vec<u8>,
    width_height: &str,
    loads: &mut Vec<usize>,
    lats: &mut Vec<u128>,
) {
    for _i in 0..5 {
        interval.tick().await;
        let now = Instant::now();
        // translate number of users to number of transcoding jobs
        // https://github.com/jethrosun/NetBricks/blob/expr/framework/src/pvn/xcdr.rs#L110
        // NOTE: 25 jobs roughly takes 1 second
        if num_of_jobs > 0 {
            for _ in 0..num_of_jobs {
                let _ = transcode(buffer.as_slice(), width_height);
            }
        }
        // TODO: better way to track this
        let elapsed = now.elapsed();

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
    if params.len() == 4 {
        println!("Parsing 3 args");
        println!("{:?}", params);
    } else {
        println!(
            "More or less than 3 args are provided. Run it with *profile_id/name node_id core_id*"
        );
        process::exit(0x0100);
    }

    let profile_id = params[1].parse::<usize>().unwrap();
    let node_id = params[2].parse::<usize>().unwrap();
    let core_id = params[3].parse::<usize>().unwrap();
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

    let (times, workload) = retrieve_workload(workload_path.to_string(), expr_time).unwrap();
    println!("retrieved workload: {}", workload_path);
    println!("times {:?}", times);
    println!("workload {:?}", workload);

    let cname = core_id.to_string() + "-" + &profile_id.to_string();
    let pname = profile_name.clone();

    let mut beginning = Instant::now();

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
    let mut loads = Vec::new();
    let mut lats = Vec::new();

    if pname == "xcdr" {
        // let mut job_count = 0;
        let mut num_of_jobs = (((count / 10) as f64 + 0.01).ceil() * 1.13).ceil() as usize;

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

            process_xcdr(
                &mut interval,
                count,
                num_of_jobs,
                &mut buffer,
                width_height,
                &mut loads,
                &mut lats,
            )
            .await;
            println!(
                "Info: {:?} users in {:?}ms with core: {:?}",
                count * 5,
                cur_time.elapsed().as_millis(),
                core
            );
            println!("Metric: {:?}", loads);
            println!("Latency(ms): {:?}", lats);

            // run until the next change
            //
            if beginning.elapsed().as_secs() >= expr_time as u64 {
                println!("Have run for {}, exiting now", expr_time);
                process::exit(0x0100);
            } else if beginning.elapsed().as_secs() >= *pivot as u64 {
                count = *workload.get(pivot).unwrap();
                pivot = match times_iter.next() {
                    Some(t) => t,
                    None => &expr_time,
                };
                num_of_jobs = (((count / 10) as f64 + 0.01).ceil() * 1.13).ceil() as usize;
                println!(
                    "WorkloadChanged, count: {:?} pivot waiting for: {:?}, num_of_jobs: {:?}",
                    count, pivot, num_of_jobs
                );
                continue;
            }
        }
    }
    // rand1-4
    else {
        let mut load = udf_load(&pname, count as f64).unwrap();
        println!("WorkloadChanged, count: {:?} load: {:?}", count, load);

        //RAM
        let mut large_vec = vec![42u128; (load.ram as u128).try_into().unwrap()];

        // File I/O
        // use buffer to store random data
        let mut buf: Vec<u8> = Vec::with_capacity((load.io * 1_000_000).try_into().unwrap()); // B to MB
        for _ in 0..buf.capacity() {
            buf.push(rand::random())
        }
        println!("buf size: {:?}", buf.capacity());
        let mut buf = buf.into_boxed_slice();

        let mut interval = time::interval(time::Duration::from_secs(1));
        loop {
            loads.clear();
            lats.clear();
            let cur_time = Instant::now();
            process_rand(
                &mut interval,
                count,
                load,
                &cname,
                &large_vec,
                &mut buf,
                &mut loads,
                &mut lats,
            )
            .await;

            println!(
                "Info: count {:?} in {:?}ms with core: {:?}",
                count * 5,
                cur_time.elapsed().as_millis(),
                core
            );
            println!("Metric: {:?}", loads);
            println!("Latency(ms): {:?}", lats);

            // run until the next change
            //
            if beginning.elapsed().as_secs() >= expr_time as u64 {
                println!("Have run for {}, exiting now", expr_time);
                process::exit(0x0100);
            } else if beginning.elapsed().as_secs() >= *pivot as u64 {
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
