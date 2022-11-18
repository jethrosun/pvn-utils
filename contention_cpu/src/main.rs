/// CPU contention: we want to use this Rust program to cause CPU contention on all the cores we
/// have.
use core_affinity::CoreId;
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
    map.insert(1, 200); // 10% work done
    map.insert(2, 600); // 30% to 50% work done
    map.insert(3, 999); // no work done

    map.remove(setup)
}

/// This function simply occupies the thread for a given fraction of the time.
fn main() {
    // get the list of ports from cmd args and cast into a Vec
    let params: Vec<String> = env::args().collect();

    // len of params will be number of args +1
    if params.len() == 3 {
        println!("Parse 2 args");
        println!("Setup: {:?}, Running processes: {:?}", params[1], params[2]);
        if params[1].parse::<usize>().unwrap() == 0 {
            process::exit(0x0100);
        }
    } else {
        println!("More or less than 2 args are provided. Run it with *setup num_of_process*");
        process::exit(0x0100);
    }

    // contention setup
    let setup = params[1].parse::<usize>().unwrap();
    // num of process per core
    let num_of_process_per_core = params[2].parse::<u64>().unwrap();

    // read setup and translate to CPU contention in milliseconds
    let run_time = read_setup(&setup).unwrap();
    // let run_time = read_setup(&setup).unwrap() / num_of_process_per_core;

    // The regular way to get core ids are not going work as we have configured isol cpus to reduce context switches for DPDK and our things.
    // We want to cause equal pressure to all of the cores for CPU contention
    let mut core_ids = Vec::new();
    for idx in 1..4 {
        core_ids.push(CoreId { id: idx });
    }
    core_ids.push(CoreId { id: 5 });

    let num_of_threads = core_ids.len() as u64 * num_of_process_per_core;

    let threads: Vec<_> = (0..num_of_threads)
        .zip(core_ids.iter().cycle().copied())
        .map(|(i, core_id)| {
            thread::spawn(move || {
                core_affinity::set_for_current(core_id);
                println!("thread: {:?} is on core id: {:?}", i, core_id);
                // loop to execute job
                let _sleep_time = Duration::from_millis(1000 - run_time);
                let _run_time = Duration::from_millis(run_time);
                let mut rng = rand::thread_rng();

                loop {
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
                    // println!("start elapsed {:?}", _now.elapsed());
                }
            })
        })
        .collect();

    for t in threads {
        t.join().unwrap()
    }
}
