//! Simple Rust program that can generate enough Disk I/O contention. We have to use two files to
//! generate enough I/O. To isolate the impact we also want cpu pining.
extern crate rand;

use std::collections::HashMap;
use std::env;
use std::fs::{File, OpenOptions};
use std::io::Write;
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
    map.insert(1, 5);
    map.insert(2, 50);
    map.insert(3, 200);

    map.remove(setup)
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

fn main() {
    // get the list of ports from cmd args and cast into a Vec
    let params: Vec<String> = env::args().collect();

    // len of params will be number of args +1
    if params.len() == 3 {
        println!("Parse 3 args");
        println!(
            "Setup: {:?}, core id: {:?}, disk: {:?}",
            params[1], params[2], params[3]
        );
        if params[1].parse::<usize>().unwrap() == 0 {
            process::exit(0x0100);
        }
    } else {
        println!("More or less than 1 args are provided. Run it with *setup*");
        process::exit(0x0100);
    }

    let setup = params[1].parse::<usize>().unwrap();
    let core_id = params[2].parse::<usize>().unwrap();
    let disk = params[3].parse::<String>().unwrap();
    let buf_size = read_setup(&setup).unwrap();

    // Disk I/O contention
    let _sleep_time = Duration::from_millis(50);
    let _second = Duration::from_secs(1);

    thread::spawn(move || {
        let mut counter = 0;
        let start = Instant::now();

        // use buffer to store random data
        let mut buf: Vec<u8> = Vec::with_capacity(buf_size * 1_000_000); // B to MB
        for _ in 0..buf.capacity() {
            buf.push(rand::random())
        }
        let buf = buf.into_boxed_slice();

        // let file_name = "/data/tmp/foobar".to_owned() + &core_id.to_string() + ".bin";
        let file_name = if disk == "hdd" {
            "/data/tmp/foobar".to_owned() + &core_id.to_string() + ".bin"
        } else {
            "/home/jethros/data/tmp/foobar".to_owned() + &core_id.to_string() + ".bin"
        };

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
            let _ = file_io(&mut counter, &mut file, buf.clone());

            if start.elapsed() >= Duration::from_secs(181) {
                println!("have run for 180 seconds with counter {:?}", counter);
            }

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
