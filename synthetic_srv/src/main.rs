extern crate faktory;
extern crate resize;
extern crate y4m;

use core_affinity::CoreId;
use faktory::ConsumerBuilder;
use resize::Pixel::Gray8;
use resize::Type::Triangle;
use std::env;
use std::fs::File;
use std::process;
use std::time::Instant;
use std::{io, thread};

/// Execute a job.
fn execute(cpu_load: u64, ram_load: u64, io_load: u64, name: &str) -> io::Result<()> {
    println!("",);
    // let mut infh: Box<dyn io::Read> = Box::new(File::open(&infile).unwrap());
    // let mut out = Vec::new();

    // let dst_dims: Vec<_> = width_height
    //     .split("x")
    //     .map(|s| s.parse().unwrap())
    //     .collect();

    // let mut decoder = y4m::decode(&mut infh).unwrap();

    // if decoder.get_bit_depth() != 8 {
    //     panic!(
    //         "Unsupported bit depth {}, this example only supports 8.",
    //         decoder.get_bit_depth()
    //     );
    // }
    // let (w1, h1) = (decoder.get_width(), decoder.get_height());
    // let (w2, h2) = (dst_dims[0], dst_dims[1]);
    // let mut resizer = resize::new(w1, h1, w2, h2, Gray8, Triangle);
    // let mut dst = vec![0; w2 * h2];

    // let mut encoder = y4m::encode(w2, h2, decoder.get_framerate())
    //     .with_colorspace(y4m::Colorspace::Cmono)
    //     .write_header(&mut out)
    //     .unwrap();

    // while let Ok(frame) = decoder.read_frame() {
    //     resizer.resize(frame.get_y_plane(), &mut dst);
    //     let out_frame = y4m::Frame::new([&dst, &[], &[]], None);
    //     if encoder.write_frame(&out_frame).is_err() {
    //         return;
    //     }
    // }
    Ok(())
}

fn main() {
    let start = Instant::now();
    let params: Vec<String> = env::args().collect();

    // parameters:
    //
    // CPU, CPU load, RAM load, I/O load, name
    if params.len() == 6 {
        println!("Parse 5 args");
        println!("{:?}", params);
    } else {
        println!("More or less than 2 args are provided. Run it with *setup expr_num*");
        process::exit(0x0100);
    }

    let cpu_id = params[1].parse::<usize>().unwrap();
    let cpu_load = params[2].parse::<usize>().unwrap();
    let ram_load = params[3].parse::<usize>().unwrap();
    let io_load = params[4].parse::<usize>().unwrap();
    let name = params[5].parse::<String>().unwrap();

    // The regular way to get core ids are not going work as we have configured isol cpus to reduce
    // context switches for DPDK and our things.
    // We want to cause equal pressure to all of the cores for CPU contention
    let mut core_ids = Vec::new();
    for idx in 0..6 {
        core_ids.push(CoreId { id: idx });
    }

    let handles = core_ids
        .into_iter()
        .map(|id| {
            thread::spawn(move || {
                if id.id == cpu_id {
                    // Pin this thread to a single CPU core.
                    core_affinity::set_for_current(id);
                    let mut c = ConsumerBuilder::default();

                    c.register(
                        cpu_load.to_string() + &ram_load.to_string() + &io_load.to_string() + &name,
                        move |job| -> io::Result<()> {
                            let job_args = job.args();

                            let cpu_load = job_args[0].as_u64().unwrap();
                            let ram_load = job_args[1].as_u64().unwrap();
                            let io_load = job_args[2].as_u64().unwrap();
                            let name = job_args[3].as_str().unwrap();

                            if start.elapsed().as_secs() > 180 {
                                println!("reached 180 seconds, hard stop");
                            }

                            let now_2 = Instant::now();
                            execute(cpu_load, ram_load, io_load, name);
                            println!(
                                "job: {:?} with {:?} millis with core: {:?}",
                                job.args(),
                                now_2.elapsed().as_millis(),
                                id.id
                            );
                            Ok(())
                        },
                    );

                    let mut c = c.connect(None).unwrap();

                    if let Err(e) = c.run(&["default"]) {
                        println!("worker failed: {}", e);
                    }
                }
            })
        })
        .collect::<Vec<_>>();

    for handle in handles.into_iter() {
        handle.join().unwrap();
    }
}
