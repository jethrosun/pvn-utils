extern crate crossbeam;
extern crate faktory;
extern crate resize;
extern crate y4m;

use core_affinity::{self};
use crossbeam::thread;
use faktory::ConsumerBuilder;
use resize::Pixel::Gray8;
use resize::Type::Triangle;
use std::env;
use std::fs::File;
use std::io;
use std::process;
use std::time::Instant;

/// Run the transcoding job using threading in crossbeam.
pub fn run_transcode_crossbeam(infile_str: &str, outfile_str: &str, width_height_str: &str) {
    thread::scope(|s| {
        let core_ids = core_affinity::get_core_ids().unwrap();
        let handles = core_ids.into_iter().map(|id| {
            s.spawn(move |_| {
                core_affinity::set_for_current(id);

                if id.id == 5 as usize {
                    // println!("transcode job {:?} in the queue {:?}", pivot, r.len());
                    transcode(
                        infile_str.to_string(),
                        outfile_str.to_string(),
                        width_height_str.to_string(),
                    );
                }
            })
        });
        // .collect::<Vec<_>>();

        for handle in handles.into_iter() {
            handle.join().unwrap();
        }
    })
    .unwrap();
}

/// Run the transcoding job using native threading.
pub fn run_transcode_native(pivot: u128) {
    let core_ids = core_affinity::get_core_ids().unwrap();

    let handles = core_ids.into_iter().map(|id| {
        std::thread::spawn(move || {
            core_affinity::set_for_current(id);
            // println!("id {:?}", id);

            if id.id == 5 as usize {
                // println!("Working in core {:?} as from 0-5", id);
                let infile = "/home/jethros/dev/pvn/utils/data/tiny.y4m";
                // let outfile = "out.y4m";
                let width_height = "360x24";
                for i in 0..10 {
                    let outfile = "/home/jethros/dev/pvn/utils/data/output_videos/".to_owned()
                        + &pivot.to_string()
                        + "_"
                        + &i.to_string()
                        + ".y4m";
                    transcode(
                        infile.to_string(),
                        outfile.to_string(),
                        width_height.to_string(),
                    );
                }
            }
        })
    });
    // .collect::<Vec<_>>();

    for handle in handles.into_iter() {
        handle.join().unwrap();
    }
}

/// Actual video transcoding.
///
/// We set up all the parameters for the transcoding job to happen.
fn transcode(infile: String, outfile: String, width_height: String) {
    // println!("transcoding");
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
    let mut vcounter = 0;
    let now = Instant::now();

    // get the list of ports from cmd args and cast into a Vec
    let params: Vec<String> = env::args().collect();

    if params.len() == 4 {
        println!("Parse 3 args");
        println!("{:?} {:?} {:?} ", params[1], params[2], params[3]);
    } else if params.len() < 4 {
        println!("Less than 3 args are provided. Run it with *PORT1 PORT2 expr_num*");
        process::exit(0x0100);
    } else {
        println!("More than 2 args are provided. Run it with *PORT1 PORT2 expr_num*");
        // println!("{:?}", ports);
        process::exit(0x0100);
    }

    // let default_faktory_conn = "tcp://:some_password@localhost:".to_string() + &params[1];
    let default_faktory_conn = "tcp://localhost:7419";

    let mut c = ConsumerBuilder::default();
    c.register(
        "app-xcdr_t-".to_owned() + &params[3],
        |job| -> io::Result<()> {
            // println!("{:?}", job);
            // Job { jid: "uHZtO6qTxNurjck4", queue: "default", kind: "app-xcdr_t", args: [String("/home/jethros/dev/pvn-utils/data/tiny.y4m"), String("/home/jethros/dev/pvn-utils/data/output_videos/321_0.y4m"), String("360x24")], created_at: Some(2020-05-06T22:34:34.479399561Z), enqueued_at: Some(2020-05-06T22:34:34.479430746Z), at: None, reserve_for: Some(600), retry: Some(25), priority: None, backtrace: None, failure: None, custom: {} }
            // println!("{:?}", job.args());
            let job_args = job.args();

            let infile_str = job_args[0].as_str().unwrap();
            let outfile_str = job_args[1].as_str().unwrap();
            let width_height_str = job_args[2].as_str().unwrap();

            run_transcode_crossbeam(infile_str, outfile_str, width_height_str);
            // run_transcode_crossbeam(
            //     infile_str.to_string(),
            //     outfile_str.to_string(),
            //     width_height_str.to_string(),
            // );
            println!("video transcoded",);

            Ok(())
        },
    );

    println!("{:?}", default_faktory_conn);
    let mut c = c.connect(Some(&default_faktory_conn)).unwrap();

    println!("before run");
    if let Err(e) = c.run(&["default"]) {
        println!("worker failed: {}", e);
    }
    if now.elapsed().as_secs() == 600 {
        println!("Metric: ",);
    }
    // println!("Hello, world!");
}
