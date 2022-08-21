use failure::Fallible;
use rand::Rng;
use resize::Pixel::Gray8;
use serde_json::{from_reader, json, Value};
use std::collections::HashMap;
use std::convert::TryInto;
use std::fs::{File, OpenOptions};
use std::io::{Error, ErrorKind, Write};
use std::time::{Duration, Instant};
use std::vec::Vec;
use std::{env, io, process, thread, vec};

const GB_SIZE: f64 = 1_000_000_000.0;

#[derive(Copy, Clone, Debug)]
pub struct Load {
    cpu: u64,
    ram: u64,
    io: u64,
}

/// Map different setup to memory resource intensiveness. We are mapping setup into size of u128,
/// which is the largest size we can use setup: 10GB, 20GB, 50GB. 50GB is definitely causing too
/// much paging.
pub fn udf_load(profile_name: &str, count: f64) -> Option<Load> {
    let cpu_load = 300.0; // 50%
    let ram_load = 0.1; // 1GB
    let io_load = 50.0; // 1 P2P user from logs

    let load = match profile_name {
        "tlsv" => Load {
            cpu: 20 * count as u64,
            ram: 0 as u64,
            io: 0 as u64,
        },
        "p2p" => Load {
            cpu: 0 as u64,
            ram: 0 as u64,
            io: 50 * count as u64,
        },
        "rand1" => Load {
            cpu: ((0.0475 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.0271 * GB_SIZE * ram_load * count) as f64).ceil() as u64,
            io: ((0.0413 * io_load * count) as f64).ceil() as u64,
        },
        "rand2" => Load {
            cpu: ((0.3449 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.639 * GB_SIZE * ram_load * count) as f64).ceil() as u64,
            io: ((0.5554 * io_load * count) as f64).ceil() as u64,
        },
        "rand3" => Load {
            cpu: ((0.1555 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.6971 * GB_SIZE * ram_load * count) as f64).ceil() as u64,
            io: ((0.833 * io_load * count) as f64).ceil() as u64,
        },
        "rand4" => Load {
            cpu: ((0.9647 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.6844 * GB_SIZE * ram_load * count) as f64).ceil() as u64,
            io: ((0.0955 * io_load * count) as f64).ceil() as u64,
        },
        _ => {
            println!("profile name is something else!");
            return None;
        }
    };
    Some(load)
}

pub fn retrieve_workload(
    file_path: String,
    expr_time: usize,
) -> serde_json::Result<(Vec<usize>, HashMap<usize, u64>)> {
    println!("DEBUG: workload path is {:?}", file_path);
    let file = File::open(file_path).expect("file should open read only");
    let json_data: serde_json::Value =
        serde_json::from_reader(file).expect("file should be proper JSON");
    // println!("DEBUG: json data {:?}", json_data);

    let mut udf_workload: HashMap<usize, u64> = HashMap::new();
    for t in 0..expr_time {
        let count = match json_data.get(t.to_string()) {
            Some(val) => val.as_u64().unwrap(),
            None => continue,
        };
        udf_workload.insert(t, count);
    }
    let mut vec: Vec<usize> = udf_workload.clone().into_keys().collect();
    vec.sort_unstable();
    Ok((vec, udf_workload))
}

pub fn schedule_udf_workload() -> io::Result<()> {
    !unimplemented!()
}

pub fn map_profile(file_path: String) -> serde_json::Result<HashMap<usize, String>> {
    // println!("DEBUG: profile path is {:?}", file_path);
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

pub fn file_io(counter: &mut i32, f: &mut File, buf: Box<[u8]>) {
    // write sets * 50mb to file
    f.write_all(&buf).unwrap();
    f.flush().unwrap();

    // // measure read throughput
    // f.seek(SeekFrom::Start(0)).unwrap();
    // // read sets * 50mb mb from file
    // f.read_exact(&mut buf).unwrap();
    *counter += 1;
}

/// Execute the work we need in exactly one second
///
/// Unit of CPU, RAM, I/O load is determined from measurment/analysis
pub fn execute(name: &str, load: Load) -> io::Result<()> {
    let mut beginning = Instant::now();

    let _sleep_time = Duration::from_millis(50);
    // counting the iterations
    let mut counter = 0;

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
    let file_name = "/data/foobar".to_owned() + name + ".bin";

    // files for both cases
    let mut file = OpenOptions::new()
        .write(true)
        .read(true)
        .create(true)
        .open(file_name)
        .unwrap();

    // File I/O
    let _ = file_io(&mut counter, &mut file, buf.clone());

    // make sure we run for exactly one second
    loop {
        let cpu_run_time = Duration::from_millis(load.cpu);
        let mut cpu_time = Duration::from_millis(0);

        // sleep a little
        thread::sleep(_sleep_time);

        loop {
            // CPU work
            // we generate 100 randon numbers
            if cpu_time < cpu_run_time {
                let mut _now = Instant::now();
                let _ = rng.gen_range(0..100);
                cpu_time += _now.elapsed();
            }

            // RAM
            for i in 0..vec_size as usize / 256 {
                let _ = large_vec[i * 256];
                // println!("current value: {:?}", t);
            }
            counter += 1;

            if beginning.elapsed() >= Duration::from_millis(990) {
                break;
            }
            // if _now.elapsed() >= _sleep_time + _run_time {
            //     _now = Instant::now();
            //     break;
            // }
        }
        println!("{} rounds since {:?}", counter, beginning.elapsed());

        if beginning.elapsed() >= Duration::from_millis(990) {
            break;
        }
    }
    Ok(())
}
