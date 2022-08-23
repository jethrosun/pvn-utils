extern crate failure;
extern crate rand;
extern crate resize;
extern crate serde_json;
extern crate time;
extern crate y4m;

use crate::lib::*;
use crate::transcode::*;
use core_affinity::CoreId;
use std::convert::TryInto;
use std::fs::OpenOptions;
use std::time::{Duration, Instant};
use std::vec;
use std::{env, process, thread};

mod lib;
mod transcode;

fn main() {
    let expr_time = 1800;
    // let start = Instant::now();

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
    // let profile_map_path = "/home/jethros/dev/pvn/workload/results/profile_map.json";
    let profile_map_path = "/udf/profile_map.json";

    let profile_map = map_profile(profile_map_path.to_string()).unwrap();
    let profile_name = profile_map.get(&profile_id).unwrap().clone();
    println!(
        "node id {}, core id {}, profile id {} // name {:?}",
        node_id, core_id, profile_id, profile_name
    );

    // get workload based on node_id/core_id/profile_id
    // let workload_path = "/home/jethros/dev/pvn/workload/results/udf_profile".to_owned()
    //     + &profile_id.to_string()
    //     + "_node"
    //     + &node_id.to_string()
    //     + "_core"
    //     + &core_id.to_string()
    //     + ".json";
    let workload_path = "/udf/udf_profile".to_owned()
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

    let handler = thread::spawn(move || {
        core_affinity::set_for_current(core);
        println!("thread pined to {:?}", core);
        let beginning = Instant::now();
        let mut count = if times.contains(&0) {
            *workload.get(&0).unwrap()
        } else {
            0 as u64
        };
        let mut times_iter = times.iter();
        let mut pivot = times_iter.next().unwrap();
        pivot = times_iter.next().unwrap();
        println!(
            "Workload started, count: {:?}, waiting for: {:?}",
            count, pivot,
        );

        if pname == "xcdr" {
            let mut job_count = 0;
            let mut num_of_jobs = (((count / 10) as f64 + 0.01).ceil() * 1.13).ceil() as usize;

            loop {
                // loop {
                let now = Instant::now();

                // translate number of users to number of transcoding jobs
                // https://github.com/jethrosun/NetBricks/blob/expr/framework/src/pvn/xcdr.rs#L110
                // NOTE: 25 jobs roughly takes 1 second
                for x in 0..num_of_jobs {
                    let _ = transcode();
                }
                job_count += num_of_jobs;
                // TODO: better way to track this
                println!(
                    "\ttranscoded {:?} jobs in {:?} millis with core: {:?}",
                    num_of_jobs,
                    now.elapsed().as_millis(),
                    core
                );
                if now.elapsed() < Duration::from_millis(990) {
                    thread::sleep(Duration::from_millis(990) - now.elapsed());
                }
                // }

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
                        "Workload changed, count: {:?}, pivot waiting for: {:?}, num_of_jobs: {:?}",
                        count, pivot, num_of_jobs
                    );
                    continue;
                }
            }
        }
        // rand1-4
        else {
            let mut load = udf_load(&pname, count as f64).unwrap();
            println!("count {:?}, {:?}", count, load);

            //RAM
            let mut large_vec = vec![42u128; (load.ram as u128).try_into().unwrap()];

            // File I/O
            // use buffer to store random data
            let mut buf: Vec<u8> = Vec::with_capacity((load.io * 1_000_000).try_into().unwrap()); // B to MB
            for _ in 0..buf.capacity() {
                buf.push(rand::random())
            }
            let buf = buf.into_boxed_slice();

            // files
            let file_name = "/data/foobar".to_owned() + &cname + ".bin";
            let mut file = OpenOptions::new()
                .write(true)
                .read(true)
                .create(true)
                .open(file_name)
                .unwrap();

            // let mut report_time = 300;
            loop {
                let now = Instant::now();

                let _ = execute(load, &large_vec, &mut file, buf.clone());
                println!(
                    "\tjob: {:?} ({:?}) with {:?} millis with core: {:?}",
                    count,
                    load,
                    now.elapsed().as_millis(),
                    core
                );
                if now.elapsed() < Duration::from_millis(990) {
                    thread::sleep(Duration::from_millis(990) - now.elapsed());
                }

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
                        "Workload changed, count: {:?}, pivot waiting for: {:?}, new load {:?}",
                        count, pivot, load
                    );
                    large_vec.resize(load.ram as usize, 42u128);
                    continue;
                }
            }
        }
    });

    handler.join().unwrap();
}
