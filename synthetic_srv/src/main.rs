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

const GB_SIZE: usize = 1_000_000_000;

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
pub fn read_setup(cpu_load: u64, ram_load: u64, io_load: u64) -> Option<Load> {
    Some(Load {
        cpu: 100 as u64,
        ram: (1 * GB_SIZE / 16) as u64,
        io: 20 as u64,
    })
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
    let profile_name = profile_map.get(&profile_id).unwrap();

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
                    let rdr = "rdr".to_string();
                    let xcdr = "xcdr".to_string();

                    match pname {
                        rdr => {
                            let num_of_users = 20;
                            let rdr_users = rdr_read_rand_seed(num_of_users, 2).unwrap();
                            let usr_data_dir = rdr_read_user_data_dir("/home/jethros/setup".to_string()).unwrap();

                            let workload_path = "/home/jethros/dev/pvn/utils/workloads/rdr_pvn_workloads/rdr_pvn_workload_5.json";
                            println!("{:?}", workload_path);
                            let mut rdr_workload = rdr_load_workload(workload_path.to_string(), expr_time , rdr_users.clone()).unwrap();
                            println!("Workload is generated",);

                            // Browser list.
                            let mut browser_list: HashMap<i64, Browser> = HashMap::new();

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
                                if let Some(wd) =  rdr_workload.remove(&cur_time) {
                                    println!("{:?} min, {:?} second", min, rest_sec);
                                    if let Some((oks, errs, timeouts, closeds, visits, elapsed)) = rdr_scheduler_ng(&cur_time, &rdr_users, wd, &browser_list) {
                                        num_of_ok += oks;
                                        num_of_err += errs;
                                        num_of_timeout += timeouts;
                                        num_of_closed += closeds;
                                        num_of_visit += visits;
                                        elapsed_time.push(elapsed);
                                    }
                                }
                            }
                        }
                        xcdr => {
                            c.register(cname.clone(), move |job| -> io::Result<()> {
                                let job_args = job.args();

                                let infile_str = job_args[0].as_str().unwrap();
                                // let outfile_str = job_args[1].as_str().unwrap();
                                let width_height_str = job_args[2].as_str().unwrap();

                                let infh: Box<dyn io::Read> =
                                    Box::new(File::open(infile_str).unwrap());

                                if start.elapsed().as_secs() > expr_time as u64 {
                                    println!("reached {} seconds, hard stop", expr_time);
                                }
                                let now_2 = Instant::now();
                                transcode(infh, width_height_str.to_string());
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
                        _ => {
                            c.register(cname.clone(), move |job| -> io::Result<()> {
                                let job_args = job.args();

                                let count = job_args[0].as_u64().unwrap();
                                let load = read_setup(1, 1, 1).unwrap();
                                // let p_name = profile_name;

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
                }
            })
        })
        .collect::<Vec<_>>();

    for handle in handles.into_iter() {
        handle.join().unwrap();
    }
}