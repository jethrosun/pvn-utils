use std::collections::HashMap;
use std::env;
use std::process;
use std::thread;
use std::time::{Duration, Instant};
use std::vec;

const GB_SIZE: usize = 1073741824;

/// Map different setup to memory resource intensiveness. We are mapping setup into size of u128,
/// which is the largest size we can use
/// setup: 10GB, 20GB, 50GB
fn read_setup(setup: &usize) -> Option<usize> {
    let mut map = HashMap::new();
    map.insert(1, 10 * GB_SIZE); // 10GB
    map.insert(2, 20 * GB_SIZE); // 20GB
    map.insert(3, 30 * GB_SIZE); // 50GB

    map.remove(&setup)
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
