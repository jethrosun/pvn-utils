extern crate rand;
use std::collections::HashMap;
use std::env;
use std::fs::{File, OpenOptions};
use std::io::{Read, Seek, SeekFrom, Write};
use std::process;
use std::thread;
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

fn open_file() -> File {
    OpenOptions::new()
        .write(true)
        .read(true)
        .create(true)
        .open("/data/tmp/foobar.bin")
        .unwrap()
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

    // io
    // 50mb with random data
    let mut buf: Vec<u8> = Vec::with_capacity(buf_size * 1_000_000); // B to MB
    for _ in 0..buf.capacity() {
        buf.push(rand::random())
    }
    let mut buf = buf.into_boxed_slice();

    let mut file = open_file();

    loop {
        let _start = Instant::now();
        // println!("start");
        let mut _now = Instant::now();
        loop {
            // write sets * 50mb to file
            file.write_all(&mut buf).unwrap();
            file.flush().unwrap();

            // measure read throughput
            file.seek(SeekFrom::Start(0)).unwrap();
            // read sets * 50mb mb from file
            file.read_exact(&mut buf).unwrap();

            //
            if _now.elapsed() >= _second {
                _now = Instant::now();
                // println!("continue");
                break;
            } else {
                thread::sleep(_sleep_time);
                continue;
            }
        }
        // println!("start elapsed {:?}", _start.elapsed());
    }
}
