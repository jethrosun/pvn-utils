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

/// Actual video transcoding.
///
/// We set up all the parameters for the transcoding job to happen.
fn transcode(mut infh: Box<dyn io::Read>, width_height: String) {
    // let mut infh: Box<dyn io::Read> = Box::new(File::open(&infile).unwrap());
    let mut out = Vec::new();
    let dst_dims: Vec<_> = width_height
        .split("x")
        .map(|s| s.parse().unwrap())
        .collect();

    let mut decoder = y4m::decode(&mut infh).unwrap();

    if decoder.get_bit_depth() != 8 {
        panic!(
            "Unsupported bit depth {}, this example only supports 8.",
            decoder.get_bit_depth()
        );
    }
    let (w1, h1) = (decoder.get_width(), decoder.get_height());
    let (w2, h2) = (dst_dims[0], dst_dims[1]);
    let mut resizer = resize::new(w1, h1, w2, h2, Gray8, Triangle);
    let mut dst = vec![0; w2 * h2];

    let mut encoder = y4m::encode(w2, h2, decoder.get_framerate())
        .with_colorspace(y4m::Colorspace::Cmono)
        .write_header(&mut out)
        .unwrap();

    while let Ok(frame) = decoder.read_frame() {
        resizer.resize(frame.get_y_plane(), &mut dst);
        let out_frame = y4m::Frame::new([&dst, &[], &[]], None);
        if encoder.write_frame(&out_frame).is_err() {
            return;
        }
    }
}

fn main() {
    let start = Instant::now();
    // get the list of ports from cmd args and cast into a Vec
    let params: Vec<String> = env::args().collect();

    if params.len() == 5 {
        println!("Parse 4 args");
        println!(
            "Setup: {:?}, Port1: {:?}, Port2: {:?}, Expr: {:?}",
            params[1], params[2], params[3], params[4],
        );
    } else {
        println!("More or less than 4 args are provided. Run it with *PORT1 PORT2 expr_num*");
        process::exit(0x0100);
    }

    let _setup = params[1].parse::<usize>().unwrap();
    let expr = params[4].parse::<usize>().unwrap();

    // The regular way to get core ids are not going work as we have configured isol cpus to reduce context switches for DPDK and our things.
    // We want to cause equal pressure to all of the cores for CPU contention
    let mut core_ids = Vec::new();
    for idx in 0..6 {
        core_ids.push(CoreId { id: idx });
    }

    let handles = core_ids
        .into_iter()
        .map(|id| {
            thread::spawn(move || {
                if id.id == 3 {
                    // Pin this thread to a single CPU core.
                    core_affinity::set_for_current(id);
                    let mut c = ConsumerBuilder::default();

                    c.register(
                        "app-xcdr_".to_owned() + &expr.to_string(),
                        move |job| -> io::Result<()> {
                            let job_args = job.args();

                            let infile_str = job_args[0].as_str().unwrap();
                            // let outfile_str = job_args[1].as_str().unwrap();
                            let width_height_str = job_args[2].as_str().unwrap();

                            let infh: Box<dyn io::Read> = Box::new(File::open(infile_str).unwrap());

                            if start.elapsed().as_secs() > 600 {
                                println!("reached 600 seconds, hard stop");
                            }
                            let now_2 = Instant::now();
                            // println!("transcode with core {:?} ", id.id);
                            // transcode(
                            //     infile_str.to_string(),
                            //     outfile_str.to_string(),
                            //     width_height_str.to_string(),
                            // );
                            transcode(infh, width_height_str.to_string());
                            println!(
                                "inner: transcoded in {:?} millis with core: {:?}",
                                now_2.elapsed().as_millis(),
                                0
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
