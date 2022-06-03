extern crate faktory;
extern crate rand;

use crate::rand::Rng;
use core_affinity::CoreId;
use faktory::ConsumerBuilder;
use std::collections::HashMap;
use std::convert::TryInto;
use std::env;
use std::fs::{File, OpenOptions};
use std::io::Write;
use std::process;
use std::time::{Duration, Instant};
use std::vec;
use std::{io, thread};

const GB_SIZE: usize = 1_000_000_000;

#[derive(Copy, Clone, Debug)]
struct Load {
    cpu: u64,
    ram: u64,
    io: u64,
}

/// Map different setup to memory resource intensiveness. We are mapping setup into size of u128,
/// which is the largest size we can use setup: 10GB, 20GB, 50GB. 50GB is definitely causing too
/// much paging.
fn read_setup(cpu_load: u64, ram_load: u64, io_load: u64) -> Option<Load> {
    Some(Load {
        cpu: 100 as u64,
        ram: (1 * GB_SIZE / 16) as u64,
        io: 20 as u64,
    })
}

fn file_io(counter: &mut i32, f: &mut File, buf: Box<[u8]>) {
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
fn execute(
    cpu_load: u64,
    ram_load: u64,
    io_load: u64,
    io_disk: &str,
    name: &str,
) -> io::Result<()> {
    let load = read_setup(cpu_load, ram_load, io_load).unwrap();

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
        "/data/tmp/foobar".to_owned() + &name + ".bin"
    } else {
        "/home/jethros/data/tmp/foobar".to_owned() + &name + ".bin"
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
    let start = Instant::now();
    let params: Vec<String> = env::args().collect();

    // parameters:
    //
    // FIXME: Ideally we will only read the profile name, reading core id now just to make it work
    if params.len() == 3 {
        println!("Parse 2 args");
        println!("{:?}", params);
    } else {
        println!("More or less than 2 args are provided. Run it with *profile_name*");
        process::exit(0x0100);
    }

    let profile_name = params[1].parse::<String>().unwrap();
    let core_id = params[2].parse::<usize>().unwrap();
    // let ram_load = params[3].parse::<usize>().unwrap();
    // let io_load = params[4].parse::<usize>().unwrap();
    // let io_disk = params[5].parse::<String>().unwrap();
    // let name = params[6].parse::<String>().unwrap();

    // The regular way to get core ids are not going work as we have configured isol cpus to reduce
    // context switches for DPDK and our things.
    // We want to cause equal pressure to all of the cores for CPU contention
    let mut core_ids = Vec::new();
    for idx in 0..6 {
        core_ids.push(CoreId { id: idx });
    }

    let handles = core_ids
        .into_iter()
        .map(|id| {
            let cname = profile_name.clone();
            thread::spawn(move || {
                if id.id == core_id {
                    // Pin this thread to a single CPU core.
                    core_affinity::set_for_current(id);
                    let mut c = ConsumerBuilder::default();

                    c.register(cname, move |job| -> io::Result<()> {
                        let job_args = job.args();

                        let cpu_load = job_args[0].as_u64().unwrap();
                        let ram_load = job_args[1].as_u64().unwrap();
                        let io_load = job_args[2].as_u64().unwrap();
                        let io_disk = job_args[3].as_str().unwrap();
                        let profile_name = job_args[4].as_str().unwrap();

                        // FIXME: only run for 30 sec
                        if start.elapsed().as_secs() > 30 {
                            println!("reached 30 seconds, hard stop");
                        }

                        let now_2 = Instant::now();
                        execute(cpu_load, ram_load, io_load, io_disk, profile_name);
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
            })
        })
        .collect::<Vec<_>>();

    for handle in handles.into_iter() {
        handle.join().unwrap();
    }
}
