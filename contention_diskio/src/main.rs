//! Simple Rust program that can generate enough Disk I/O contention. We have to use two files to
//! generate enough I/O.
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
    map.insert(1, 50);
    map.insert(2, 100);
    map.insert(3, 200);

    map.remove(&setup)
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

    // use buffer to store random data
    let mut buf: Vec<u8> = Vec::with_capacity(buf_size * 1_000_000); // B to MB
    for _ in 0..buf.capacity() {
        buf.push(rand::random())
    }
    let buf = buf.into_boxed_slice();

    let mut buf2: Vec<u8> = Vec::with_capacity(buf_size * 1_000_000); // B to MB
    for _ in 0..buf2.capacity() {
        buf2.push(rand::random())
    }
    let buf2 = buf2.into_boxed_slice();

    // files for both cases
    let mut file = OpenOptions::new()
        .write(true)
        .read(true)
        .create(true)
        .open("/data/tmp/foobar.bin")
        .unwrap();

    let mut file2 = OpenOptions::new()
        .write(true)
        .read(true)
        .create(true)
        .open("/data/tmp/foobar2.bin")
        .unwrap();

    loop {
        let _start = Instant::now();
        // println!("start");
        let mut _now = Instant::now();
        loop {
            crossbeam::scope(|s| {
                let thread_l = s.spawn(|_| file_io(&mut file, buf.clone()));
                let thread_r = s.spawn(|_| file_io(&mut file2, buf2.clone()));

                let io_l = thread_l.join().unwrap();
                let io_r = thread_r.join().unwrap();

                ()
            })
            .unwrap();

            //
            if _now.elapsed() >= _second {
                _now = Instant::now();
                // println!("continue");
                break;
            } else {
                sleep(_sleep_time);
                continue;
            }
        }
    }
}
