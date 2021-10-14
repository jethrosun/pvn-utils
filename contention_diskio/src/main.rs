//! Simple Rust program that can generate enough Disk I/O contention. We have to use two files to
//! generate enough I/O. To isolate the impact we also want cpu pining.
extern crate crossbeam;
extern crate rand;

use std::collections::HashMap;
use std::env;
use std::fs::{File, OpenOptions};
use std::io::{Read, Seek, SeekFrom, Write};
use std::process;
use std::thread::sleep;
use std::time::{Duration, Instant};

/// Map different setup to disk I/O intensiveness. We are mapping these setups to disk I/O per
/// second
/// setup: 50MB, 100MB, 200MB
fn read_setup(setup: &usize) -> Option<usize> {
    let mut map = HashMap::new();
    map.insert(0, 1);
    map.insert(1, 100);
    map.insert(2, 200);
    map.insert(3, 300);

    map.remove(setup)
}

fn file_io(f: &mut File, mut buf: Box<[u8]>) {
    // write sets * 50mb to file
    f.write_all(&buf).unwrap();
    f.flush().unwrap();

    // measure read throughput
    f.seek(SeekFrom::Start(0)).unwrap();
    // read sets * 50mb mb from file
    f.read_exact(&mut buf).unwrap();
}

fn main() {
    // get the list of ports from cmd args and cast into a Vec
    let params: Vec<String> = env::args().collect();

    // len of params will be number of args +1
    if params.len() == 2 {
        println!("Parse 2 args");
        println!("Setup: {:?}", params[1],);
    } else {
        println!("More or less than 1 args are provided. Run it with *setup*");
        process::exit(0x0100);
    }

    let setup = params[1].parse::<usize>().unwrap();
    let buf_size = read_setup(&setup).unwrap();

    // Disk I/O contention
    let _sleep_time = Duration::from_millis(50);
    let _second = Duration::from_secs(1);

    let cores = core_affinity::get_core_ids().unwrap();

    // We want to use core #4 and #5 to cause disk I/O contention
    let occupied_cores = vec![4, 5];
    loop {
        for core in &cores {
            if occupied_cores.contains(&core.id) {
                let _ = crossbeam::thread::scope(|_| {
                    // pin our work to the core
                    core_affinity::set_for_current(*core);

                    // use buffer to store random data
                    let mut buf: Vec<u8> = Vec::with_capacity(buf_size * 1_000_000); // B to MB
                    for _ in 0..buf.capacity() {
                        buf.push(rand::random())
                    }
                    let buf = buf.into_boxed_slice();

                    let file_name = "/data/tmp/foobar".to_owned() + &core.id.to_string() + ".bin";

                    // files for both cases
                    let mut file = OpenOptions::new()
                        .write(true)
                        .read(true)
                        .create(true)
                        .open(file_name)
                        .unwrap();

                    loop {
                        let _start = Instant::now();
                        let mut _now = Instant::now();

                        // actual file IO
                        let _ = file_io(&mut file, buf.clone());

                        if _now.elapsed() >= _second {
                            _now = Instant::now();
                            break;
                        } else {
                            sleep(_sleep_time);
                            continue;
                        }
                    }
                });
            }
        }
    }
}
