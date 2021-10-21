//! Simple Rust program that can generate enough Disk I/O contention. We have to use two files to
//! generate enough I/O. To isolate the impact we also want cpu pining.
extern crate rand;

use core_affinity::CoreId;
use std::collections::HashMap;
use std::env;
use std::fs::{File, OpenOptions};
use std::io::{Read, Seek, SeekFrom, Write};
use std::process;
use std::thread;
use std::thread::sleep;
use std::time::{Duration, Instant};

/// Map different setup to disk I/O intensiveness. We are mapping these setups to disk I/O per
/// second
/// setup: 50MB, 100MB, 200MB
fn read_setup(setup: &usize) -> Option<usize> {
    let mut map = HashMap::new();
    map.insert(0, 1);
    map.insert(1, 200);
    map.insert(2, 500);
    map.insert(3, 900);

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

    // The regular way to get core ids are not going work as we have configured isol cpus to reduce context switches for DPDK and our things.
    // We want to cause equal pressure to all of the cores for CPU contention
    let mut core_ids = Vec::new();
    for idx in 0..6 {
        core_ids.push(CoreId { id: idx });
    }

    // Create a thread for each active CPU core.
    let handles = core_ids
        .into_iter()
        .map(|id| {
            thread::spawn(move || {
                if id.id == 0 || id.id == 1 || id.id == 4 || id.id == 5 {
                    // Pin this thread to a single CPU core.
                    core_affinity::set_for_current(id);

                    loop {
                        // use buffer to store random data
                        let mut buf: Vec<u8> = Vec::with_capacity(buf_size * 1_000_000); // B to MB
                        for _ in 0..buf.capacity() {
                            buf.push(rand::random())
                        }
                        let buf = buf.into_boxed_slice();

                        let file_name = "/data/tmp/foobar".to_owned() + &id.id.to_string() + ".bin";

                        // files for both cases
                        let mut file = OpenOptions::new()
                            .write(true)
                            .read(true)
                            .create(true)
                            .open(file_name)
                            .unwrap();

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
                }
            })
        })
        .collect::<Vec<_>>();

    for handle in handles.into_iter() {
        handle.join().unwrap();
    }
}
