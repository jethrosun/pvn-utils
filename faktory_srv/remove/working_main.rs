extern crate crossbeam;
extern crate faktory;
extern crate resize;
extern crate y4m;

use core_affinity::{self, CoreId};
use crossbeam::thread;
use crossbeam_channel::{bounded, unbounded};
use faktory::ConsumerBuilder;
use resize::Pixel::Gray8;
use resize::Type::Triangle;
use std::env;
use std::fs::File;
use std::io;
use std::process;
// use std::thread;
use std::time::{Duration, Instant};

/// Actual video transcoding.
///
/// We set up all the parameters for the transcoding job to happen.
fn transcode(infile: String, outfile: String, width_height: String) {
    let mut infh: Box<dyn io::Read> = Box::new(File::open(&infile).unwrap());
    let mut outfh: Box<dyn io::Write> = Box::new(File::create(&outfile).unwrap());
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
        .write_header(&mut outfh)
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

    let setup = params[1].parse::<usize>().unwrap();
    let expr = params[4].parse::<usize>().unwrap();
    let cores = core_affinity::get_core_ids().unwrap();
    for core in cores {
        let (tx, rx) = unbounded();
        if core.id < setup {
            thread::scope(|_| {
                core_affinity::set_for_current(core);
                let mut c = ConsumerBuilder::default();
                c.register(
                    "app-xcdr_".to_owned() + &core.id.to_string() + "-" + &expr.to_string(),
                    move |job| -> io::Result<()> {
                        let job_args = job.args();

                        let infile_str = job_args[0].as_str().unwrap();
                        let outfile_str = job_args[1].as_str().unwrap();
                        let width_height_str = job_args[2].as_str().unwrap();

                        let now_2 = Instant::now();
                        // println!("transcode with core {:?} ", id.id);
                        transcode(
                            infile_str.to_string(),
                            outfile_str.to_string(),
                            width_height_str.to_string(),
                        );
                        tx.send(now_2.elapsed().as_millis());
                        // println!("inner: transcoded in {:?} millis with core: {:?}", core.id);
                        Ok(())
                    },
                );

                let mut c = c.connect(None).unwrap();

                if let Err(e) = c.run(&["default"]) {
                    println!("worker failed: {}", e);
                }
            });

            if rx.len() >= 10000 {
                for n in rx {
                    println!("n: {:?}", n);
                }
            }
        }
    }
}