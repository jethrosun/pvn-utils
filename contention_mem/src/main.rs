//! Simple Rust program that generate memory contention. Our memory setup is 64GB memory with 20GB
//! allocated for huge page (DPDK) and 40GB left. We also allocated 32GB as virtual memory (swap).
use core_affinity::CoreId;
use std::collections::HashMap;
use std::env;
use std::process;
use std::thread;
use std::time::{Duration, Instant};
use std::vec;

const GB_SIZE: usize = 1_000_000_000;

/// Map different setup to memory resource intensiveness. We are mapping setup into size of u128,
/// which is the largest size we can use setup: 10GB, 20GB, 50GB. 50GB is definitely causing too
/// much paging.
fn read_setup(setup: &usize) -> Option<usize> {
    let mut map = HashMap::new();
    map.insert(0, 0); // 10GB
    map.insert(1, 30 * GB_SIZE); // 30GB
    map.insert(2, 50 * GB_SIZE); // 50GB
    map.insert(3, 80 * GB_SIZE); // 80GB

    map.remove(setup)
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

    // counting the iterations
    let mut counter = 0;
    let now = Instant::now();

    // read setup and translate to vector size
    let vec_size = read_setup(&setup).unwrap() / 16;

    // let _sleep_time = Duration::from_millis(500);
    let _sleep_time = Duration::from_millis(900);

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
                if id.id == 4 {
                    // Pin this thread to a single CPU core.
                    core_affinity::set_for_current(id);
                    let large_vec = vec![42u128; vec_size];
                    loop {
                        thread::sleep(_sleep_time);
                        for i in 0..vec_size / 256 {
                            let _ = large_vec[i * 256];
                            counter += 1;
                            // println!("current value: {:?}", t);
                        }
                        if counter % 1_000 == 0 {
                            println!("{} * k since {:?}", counter, now.elapsed());
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
