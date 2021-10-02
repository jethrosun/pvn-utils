extern crate crossbeam;

use rand::Rng;
use std::collections::HashMap;
use std::env;
use std::process;
use std::thread;
use std::time::{Duration, Instant};

/// Map different setup to CPU resource intensiveness. We are mapping these time into millisecond
/// in a second that need to run loop
/// setup: 25%, 50%, 90%
fn read_setup(setup: &usize) -> Option<u64> {
    let mut map = HashMap::new();
    map.insert(0, 1);
    map.insert(1, 50);
    map.insert(2, 500);
    map.insert(3, 900);

    map.remove(setup)
}

/// This function simply occupies the thread for a given fraction of the time.
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

    // read setup and translate to CPU contention in milliseconds
    let run_time = read_setup(&setup).unwrap();

    let cores = core_affinity::get_core_ids().unwrap();
    // let occupied_cores = vec![3];
    let occupied_cores = vec![1, 2, 3, 4, 5, 6];
    for core in cores {
        if occupied_cores.contains(&core.id) {
            let _ = crossbeam::thread::scope(|_| {
                // pin our work to the core
                core_affinity::set_for_current(core);

                // loop to execute job
                let _sleep_time = Duration::from_millis(1000 - run_time);
                let _run_time = Duration::from_millis(run_time);
                let mut rng = rand::thread_rng();

                loop {
                    let start = Instant::now();
                    if run_time == 1000 {
                        loop {}
                    } else {
                        // println!("start");
                        let mut _now = Instant::now();
                        thread::sleep(_sleep_time);
                        // println!("\tsleeped {:?}", _now.elapsed());
                        loop {
                            let _ = rng.gen_range(0..10);
                            if _now.elapsed() >= _sleep_time + _run_time {
                                _now = Instant::now();
                                // println!("\tbreak");
                                break;
                            }
                        }
                    }
                    // println!("start elapsed {:?}", start.elapsed());
                }
            });
        }
    }
}
