use resize::Pixel::Gray8;
use resize::Type::Triangle;
use std::sync::MutexGuard;
use std::time::{Duration, Instant};
use std::vec::Vec;
use std::{io, vec};

static WIDTH_HEIGHT: &str = "360x24";

/// translate number of users to number of transcoding jobs
/// https://github.com/jethrosun/NetBricks/blob/expr/framework/src/pvn/xcdr.rs#L110
pub fn transcode_jobs(
    _count: u64,
    num_of_jobs: usize,
    infh: MutexGuard<Vec<u8>>,
) -> io::Result<Duration> {
    let beginning = Instant::now();
    // println!("count: {:?}, num of job {:?}", _count, num_of_jobs);

    for _ in 0..num_of_jobs {
        let mut out = Vec::new();
        let dst_dims: Vec<_> = WIDTH_HEIGHT
            .split("x")
            .map(|s| s.parse().unwrap())
            .collect();

        let mut decoder = y4m::decode(infh.as_slice()).unwrap();

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
                return Ok(beginning.elapsed());
            }
        }
    }

    Ok(beginning.elapsed())
}

/// Actual video transcoding.
///
/// We set up all the parameters for the transcoding job to happen.
// pub fn transcode(infh: &mut Box<dyn io::Read>, width_height: &str) {
#[allow(dead_code)]
pub fn transcode(infh: &[u8], width_height: &str) {
    // let mut infh: Box<dyn io::Read> = Box::new(File::open(&infile).unwrap());
    let mut out = Vec::new();
    let dst_dims: Vec<_> = width_height
        .split("x")
        .map(|s| s.parse().unwrap())
        .collect();

    let mut decoder = y4m::decode(infh).unwrap();

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
