use rand::Rng;
use std::collections::HashMap;
use std::fs::{File, OpenOptions};
use std::io::Write;
use std::time::{Duration, Instant};
use std::vec::Vec;
use std::{io, thread};

const MB_SIZE: f64 = 1_000_000.0;
const RAND_GEN_SIZE: f64 = 20_000_000.0;

#[derive(Copy, Clone, Debug)]
pub struct Load {
    pub cpu: u64,
    pub ram: u64,
    pub io: u64,
}

/// Map different setup to memory resource intensiveness. We are mapping setup into size of u128,
/// which is the largest size we can use setup: 10GB, 20GB, 50GB. 50GB is definitely causing too
/// much paging.
pub fn udf_load(profile_name: &str, count: f64) -> Option<Load> {
    // cpu_cap = 500
    // mem_cap = 54 * 1000 # 54GB to MB
    // io_cap = 155 * 1000 # 155MB/s to KB
    let cpu_load = RAND_GEN_SIZE; // # of generated random 0..100 numbers
    let ram_load = 100.0; // MB
    let io_load = 20.0; // MB: 1 P2P user from logs

    let load = match profile_name {
        // job: 6 (Load { cpu: 29, ram: 3252000, io: 25 })
        "rand1" => Load {
            cpu: ((0.0475 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.0271 * MB_SIZE * ram_load * count) as f64).ceil() as u64,
            io: ((0.0413 * io_load * count) as f64).ceil() as u64,
        },
        "rand2" => Load {
            cpu: ((0.3449 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.639 * MB_SIZE * ram_load * count) as f64).ceil() as u64,
            io: ((0.5554 * io_load * count) as f64).ceil() as u64,
        },
        "rand3" => Load {
            cpu: ((0.1555 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.6971 * MB_SIZE * ram_load * count) as f64).ceil() as u64,
            io: ((0.833 * io_load * count) as f64).ceil() as u64,
        },
        "rand4" => Load {
            cpu: ((0.9647 * cpu_load * count) as f64).ceil() as u64,
            ram: ((0.6844 * MB_SIZE * ram_load * count) as f64).ceil() as u64,
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

//pub fn file_io(counter: &mut i32, f: &mut File, buf: &mut Box<[u8]>) {
pub fn file_io(f: &mut File, buf: &mut Box<[u8]>) {
    // write sets * 50mb to file
    f.write_all(&buf).unwrap();
    f.flush().unwrap();

    // // measure read throughput
    // f.seek(SeekFrom::Start(0)).unwrap();
    // // read sets * 50mb mb from file
    // f.read_exact(&mut buf).unwrap();
    // *counter += 1;
}

/// Execute the work we need in exactly one second
///
/// Unit of CPU, RAM, I/O load is determined from measurment/analysis
pub fn execute(
    load: Load,
    cname: &String,
    large_vec: &Vec<u128>,
    // file: &mut File,
    buf: &mut Box<[u8]>,
) -> io::Result<Duration> {
    let beginning = Instant::now();

    // let _sleep_time = Duration::from_millis(50);
    // counting the iterations
    // let mut counter = 0;

    // CPU
    let mut rng = rand::thread_rng();

    let file_name = "/data/foobar".to_owned() + cname + ".bin";
    let mut file = OpenOptions::new()
        .write(true)
        .read(true)
        .create(true)
        .open(file_name)
        .unwrap();

    // RAM
    for i in 0..load.ram as usize / 256 {
        let _ = large_vec[i * 256];
        // println!("current value: {:?}", t);
    }

    // I/O
    // let _ = file_io(&mut counter, &mut file, buf);
    let _ = file_io(&mut file, buf);

    // RAM
    for i in 0..load.ram as usize / 256 {
        let _ = large_vec[i * 256];
        // println!("current value: {:?}", t);
    }

    // CPU work
    // just run the random number generator based on the load number
    for _ in 0..load.cpu {
        let _: usize = rng.gen_range(0..100);
    }

    // RAM
    for i in 0..load.ram as usize / 256 {
        let _ = large_vec[i * 256];
        // println!("current value: {:?}", t);
    }

    // sleep a little
    let elapsed_time = beginning.elapsed();
    let _sleep_time = Duration::from_millis(990) - elapsed_time;
    thread::sleep(_sleep_time);

    Ok(elapsed_time)
}
