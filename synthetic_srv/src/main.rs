extern crate failure;
extern crate faktory;
extern crate headless_chrome;
extern crate rand;
extern crate resize;
extern crate rshttp;
extern crate rustc_serialize;
extern crate serde_json;
extern crate time;
extern crate tiny_http;
extern crate y4m;

use crate::lib::*;
use crate::rand::Rng;
use core_affinity::CoreId;
use faktory::ConsumerBuilder;
use headless_chrome::Browser;
use std::collections::HashMap;
use std::convert::TryInto;
use std::fs::{File, OpenOptions};
use std::io::Write;
use std::time::{Duration, Instant};
use std::{env, io, process, thread, vec};

mod lib;

const GB_SIZE: f64= 1_000_000_000.0;

#[derive(Copy, Clone, Debug)]
pub struct Load {
    cpu: u64,
    ram: u64,
    io: u64,
}

pub fn map_profile(file_path: String) -> serde_json::Result<HashMap<usize, String>> {
    let file = File::open(file_path).expect("file should open read only");
    let json_data: serde_json::Value =
        serde_json::from_reader(file).expect("file should be proper JSON");
    let num_of_profiles = 8;

    let mut profile_map: HashMap<usize, String> = HashMap::new();
    for p in 1..num_of_profiles + 1 {
        let profile = match json_data.get(p.to_string()) {
            Some(val) => val.as_str().unwrap(),
            None => continue,
        };
        profile_map.insert(p, profile.to_string());
    }

    Ok(profile_map)
}

/// Map different setup to memory resource intensiveness. We are mapping setup into size of u128,
/// which is the largest size we can use setup: 10GB, 20GB, 50GB. 50GB is definitely causing too
/// much paging.
pub fn udf_load(profile_name: &str, count: f64) -> Option<Load> {
    let load = match profile_name {
    "tlsv" => {Load {
        cpu: 5 * count as u64,
        ram: 0 as u64,
        io: 0 as u64,
    }},
    "p2p" =>  {Load {
        cpu: 0 as u64,
        ram: 0 as u64,
        io: 20 * count  as u64,
    }},
    "rand1" => {Load {
        cpu: ((0.0475*10.0*count) as f64).ceil() as u64,
        ram: ((0.0271 *GB_SIZE / 16.0*count) as f64).ceil() as u64,
        io: ((0.0413*20.0*count) as f64).ceil() as u64
    }},
"rand2" => {Load {
        cpu: ((0.3449*10.0*count) as f64).ceil() as u64,
        ram: ((0.639 *GB_SIZE / 16.0*count) as f64).ceil() as u64,
        io: ((0.5554*20.0*count) as f64).ceil() as u64
    }},
"rand3" => {Load {
        cpu: ((0.1555*10.0*count) as f64).ceil() as u64,
        ram: ((0.6971 *GB_SIZE / 16.0*count) as f64).ceil() as u64,
        io: ((0.833*20.0*count) as f64).ceil() as u64
    }},
"rand4" => {Load {
        cpu: ((0.9647*10.0*count) as f64).ceil() as u64,
        ram: ((0.6844 *GB_SIZE / 16.0*count) as f64).ceil() as u64,
        io: ((0.0955*20.0*count) as f64).ceil() as u64
    }},
    _ => {
println!("something else!");
return None
    }
};
   Some(load)
}

pub fn file_io(counter: &mut i32, f: &mut File, buf: Box<[u8]>) {
    // write sets * 50mb to file
    f.write_all(&buf).unwrap();
    f.flush().unwrap();

    *counter += 1;
    // // measure read throughput
    // f.seek(SeekFrom::Start(0)).unwrap();
    // // read sets * 50mb mb from file
    // f.read_exact(&mut buf).unwrap();
}

/// Execute a job.
///
/// Unit of CPU, RAM, I/O load is determined from measurment/analysis
pub fn execute(name: &str, load: Load) -> io::Result<()> {
    let io_disk = "hdd";

    // counting the iterations
    let mut counter = 0;
    let mut now = Instant::now();

    // CPU
    let mut rng = rand::thread_rng();

    //RAM
    let vec_size = load.ram;
    let large_vec = vec![42u128; (vec_size as u128).try_into().unwrap()];

    // I/O
    // use buffer to store random data
    let mut buf: Vec<u8> = Vec::with_capacity((load.io * 1_000_000).try_into().unwrap()); // B to MB
    for _ in 0..buf.capacity() {
        buf.push(rand::random())
    }
    let buf = buf.into_boxed_slice();

    // let file_name = "/data/tmp/foobar".to_owned() + &core_id.to_string() + ".bin";
    let file_name = if io_disk == "hdd" {
        "/data/tmp/foobar".to_owned() + name + ".bin"
    } else {
        "/home/jethros/data/tmp/foobar".to_owned() + name + ".bin"
    };

    // files for both cases
    let mut file = OpenOptions::new()
        .write(true)
        .read(true)
        .create(true)
        .open(file_name)
        .unwrap();

    loop {
        // CPU work
        let _sleep_time = Duration::from_millis(1000 - load.cpu);
        let _run_time = Duration::from_millis(load.cpu);

        let _ = rng.gen_range(0..10);

        // RAM
        for i in 0..vec_size as usize / 256 {
            let _ = large_vec[i * 256];
            counter += 1;
            // println!("current value: {:?}", t);
        }
        if counter % 1_000 == 0 {
            println!("{} * k since {:?}", counter, now.elapsed());
        }

        // actual file IO
        let _ = file_io(&mut counter, &mut file, buf.clone());

        if now.elapsed() >= _sleep_time + _run_time {
            now = Instant::now();
            // println!("\tbreak");
            break;
        }
    }
    // println!("start elapsed {:?}", _now.elapsed());

    // I/O
    // Disk I/O contention
    let _sleep_time = Duration::from_millis(50);
    let _second = Duration::from_secs(1);

    Ok(())
}

fn main() {
    // 10 min == 600 sec
    let expr_time = 600;
    let start = Instant::now();
    let params: Vec<String> = env::args().collect();

    if params.len() == 3 {
        println!("Parse 2 args");
        println!("{:?}", params);
    } else {
        println!("More or less than 2 args are provided. Run it with *core_id profile_id/name*");
        process::exit(0x0100);
    }

    let core_id = params[1].parse::<usize>().unwrap();
    let profile_id = params[2].parse::<usize>().unwrap();

    let mut core_ids = Vec::new();
    for idx in 0..6 {
        core_ids.push(CoreId { id: idx });
    }

    let profile_map_path = "/home/jethros/dev/pvn/utils/workloads/udf/profile_map.json";
    let profile_map = map_profile(profile_map_path.to_string()).unwrap();
    println!(
        "core id {}, profile id {}, profile map {:?}",
        core_id, profile_id, profile_map
    );
    let profile_name = profile_map.get(&profile_id).unwrap().clone();

    // println!("core id {}, profile id {}, profile name {}", core_id , profile_id, profile_name);
    let handles = core_ids
        .into_iter()
        .map(move |id| {
            let cname = core_id.to_string() + "-" + &profile_id.to_string();
            let pname = profile_name.clone();
            thread::spawn(move || {
                if id.id == core_id {
                    core_affinity::set_for_current(id);
                    let mut c = ConsumerBuilder::default();

                    if pname == "rdr" {
                        c.register(cname.clone(), move |job| -> io::Result<()> {
                            // TODO: optmize the managemenet of browser and workload
                            let job_args = job.args();
                            let num_of_users  = job_args[0].as_u64().unwrap();

                            let mut browser_list: HashMap<i64, Browser> = HashMap::new();
                            let rdr_users = rdr_read_rand_seed(num_of_users, 2).unwrap();
                            let usr_data_dir = rdr_read_user_data_dir("/home/jethros/setup".to_string()).unwrap();

                            let workload_path = "/home/jethros/dev/pvn/utils/workloads/rdr_pvn_workloads/rdr_pvn_workload_5.json";
                            println!("{:?}", workload_path);
                            let mut rdr_workload = rdr_load_workload(workload_path.to_string(), expr_time , rdr_users.clone()).unwrap();
                            println!("Workload is generated",);

                            for user in &rdr_users {
                                let browser = browser_create(&usr_data_dir).unwrap();
                                browser_list.insert(*user, browser);
                            }
                            println!("{} browsers are created ", num_of_users);

                            let _pivot = 1_usize;

                            // Metrics for measurement
                            let mut elapsed_time = Vec::new();
                            let mut num_of_ok = 0;
                            let mut num_of_err = 0;
                            let mut num_of_timeout = 0;
                            let mut num_of_closed = 0;
                            let mut num_of_visit = 0;

                            let now = Instant::now();
                            println!("Timer started");

                            let cur_time = now.elapsed().as_secs() as usize;
                            if rdr_workload.contains_key(&cur_time) {
                                // println!("pivot {:?}", cur_time);
                                let min = cur_time / 60;
                                let rest_sec = cur_time % 60;
                                println!("{:?} min, {:?} second", min, rest_sec);
                                match rdr_workload.get(&cur_time) {
                                    Some(wd) => {
                                        let (oks, errs, timeouts, closeds, visits, elapsed) = rdr_scheduler(&cur_time, &rdr_users, wd.to_vec(), &browser_list).unwrap();
                                        num_of_ok += oks;
                                        num_of_err += errs;
                                        num_of_timeout += timeouts;
                                        num_of_closed += closeds;
                                        num_of_visit += visits;
                                        elapsed_time.push(elapsed);

                                    },
                                    None => println!("no work in {}.", cur_time)
                                }
                            }
                            Ok(())
                        });
                        let mut c = c.connect(None).unwrap();

                        if let Err(e) = c.run(&["default"]) {
                            println!("worker failed: {}", e);
                        }

                    } else if pname == "xcdr" {
                        c.register(cname.clone(), move |job| -> io::Result<()> {
                            let job_args = job.args();

                            if start.elapsed().as_secs() > expr_time as u64 {
                                println!("reached {} seconds, hard stop", expr_time);
                            }
                            let now_2 = Instant::now();

                            // https://github.com/jethrosun/NetBricks/blob/expr/framework/src/pvn/xcdr.rs#L110
                            let count = job_args[0].as_u64().unwrap();
                            let num_of_jobs = ((count / 10) as f64 * 1.13).ceil() as usize;
                            for x in 0..num_of_jobs {
                                let _ = transcode();
                            }
                            println!(
                                "inner: transcoded in {:?} millis with core: {:?}",
                                now_2.elapsed().as_millis(),
                                id.id
                            );
                            Ok(())
                        });
                        let mut c = c.connect(None).unwrap();

                        if let Err(e) = c.run(&["default"]) {
                            println!("worker failed: {}", e);
                        }
                    }
                    // TLSV, P2P, rand1-4
                    else {
                        // FIXME
                        c.register(cname.clone(), move |job| -> io::Result<()> {
                            let job_args = job.args();

                            let count = job_args[0].as_u64().unwrap();
                            let load = udf_load(&pname, count as f64).unwrap();

                            if start.elapsed().as_secs() > expr_time as u64 {
                                println!("reached {} seconds, hard stop", expr_time);
                            }
                            let now_2 = Instant::now();

                            execute(&cname, load);
                            println!(
                                "job: {:?} with {:?} millis with core: {:?}",
                                job.args(),
                                now_2.elapsed().as_millis(),
                                id.id
                            );
                            Ok(())
                        });
                        let mut c = c.connect(None).unwrap();

                        if let Err(e) = c.run(&["default"]) {
                            println!("worker failed: {}", e);
                        }
                    }
                }
            })
        })
    .collect::<Vec<_>>();

    for handle in handles.into_iter() {
        handle.join().unwrap();
    }
}
