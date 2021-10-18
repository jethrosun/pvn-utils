/// CPU contention: we want to use this Rust program to cause CPU contention on all the cores we
/// have.
///
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
    map.insert(1, 100); // 10% work done
    map.insert(2, 500); // 30% to 50% work done
    map.insert(3, 950); // no work done

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

    // Retrieve the IDs of all active CPU cores.
    // let core_ids = core_affinity::get_core_ids().unwrap();

    // The regular way to get core ids are not going work as we have configured isol cpus to reduce context switches for DPDK and our things.
    // We want to cause equal pressure to all of the cores for CPU contention
    let mut core_ids = Vec::new();
    for idx in 0..6 {
        core_ids.push(CoreId { id: idx });
    }
    // cores [CoreId { id: 0 }, CoreId { id: 1 }]
    println!("cores {:?}", core_ids);

    // Create a thread for each active CPU core.
    let handles = core_ids
        .into_iter()
        .map(|id| {
            thread::spawn(move || {
                // Pin this thread to a single CPU core.
                core_affinity::set_for_current(id);
                // Do more work after this.
                // Do more work after this.
                // loop to execute job
                let _sleep_time = Duration::from_millis(1000 - run_time);
                let _run_time = Duration::from_millis(run_time);
                let mut rng = rand::thread_rng();

                loop {
                    // let start = Instant::now();
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
                    // println!("start elapsed {:?}", start.elapsed());
                }
            })
        })
        .collect::<Vec<_>>();

    for handle in handles.into_iter() {
        handle.join().unwrap();
    }
}
