use failure::Fallible;
use headless_chrome::{Browser, LaunchOptionsBuilder};
use resize::Pixel::Gray8;
use resize::Type::Triangle;
use serde_json::{from_reader, json, Value};
use std::collections::HashMap;
use std::fs::File;
use std::io;
use std::io::{Error, ErrorKind};
use std::time::{Duration, Instant};
use std::vec;
use std::vec::Vec;

/// setup profile and user data dir with different disk setup
pub fn rdr_read_user_data_dir(file_path: String) -> io::Result<String> {
    let file = File::open(file_path.clone()).expect("file should open read only");
    let read_json = file_path + "should be proper JSON";
    let json: Value = from_reader(file).expect(&read_json);

    let disk_type = match json.get("disk") {
        Some(val) => Some(val.clone()),
        None => {
            println!("disk setup should exist but not, using hdd by default..");
            Some(json!("hdd"))
        }
    };
    match disk_type {
        // --profile-directory="C:\temp\profile" --user-data-dir="C:\temp\profile\userdata"
        Some(val) => {
            // if val == "hdd" {
            //     println!("running chrome with hdd");
            //     Ok("/data/tmp/profile".to_string())
            // } else {
            //     println!("running chrome with ssd");
            //     Ok("/home/jethros/data/profile".to_string())
            // }
            Ok("/data/profile".to_string())
        }
        None => {
            println!("unable to read disk setup");
            Err(Error::new(ErrorKind::Other, "unable to read disk setup"))
        }
    }
}

/// Construct the workload from the session file.
///
/// https://kbknapp.github.io/doapi-rs/docs/serde/json/index.html
pub fn rdr_load_workload(
    file_path: String,
    num_of_secs: usize,
    rdr_users: Vec<i64>,
) -> serde_json::Result<HashMap<usize, Vec<(u64, String, i64)>>> {
    // time in second, workload in that second
    let mut workload = HashMap::<usize, Vec<(u64, String, i64)>>::with_capacity(rdr_users.len());

    let file = File::open(file_path).expect("file should open read only");
    let json_data: Value = from_reader(file).expect("file should be proper JSON");

    for sec in 0..num_of_secs {
        let mut millis: Vec<(u64, String, i64)> = Vec::new();

        let urls_now = match json_data.get(sec.to_string()) {
            Some(val) => val,
            None => continue,
        };
        for user in &rdr_users {
            let urls = match urls_now.get(user.to_string()) {
                Some(val) => val.as_array(),
                None => continue,
            };

            millis.push((
                urls.unwrap()[0].as_u64().unwrap(),
                urls.unwrap()[1].as_str().unwrap().to_string(),
                *user as i64,
            ));
        }
        millis.sort();

        workload.insert(sec, millis);
    }
    Ok(workload)
}

/// Retrieve the number of users based on our setup configuration.
pub fn rdr_retrieve_users(rdr_setup: usize) -> Option<usize> {
    let mut map = HashMap::new();
    map.insert(1, 5);
    map.insert(2, 10);
    map.insert(3, 20);
    map.insert(4, 40);
    map.insert(5, 80);
    map.insert(6, 100);
    // hack for task scheduling
    map.insert(7, 10);
    map.insert(8, 20);
    map.insert(9, 30);
    map.insert(10, 40);
    map.insert(11, 50);
    map.insert(12, 60);
    map.insert(13, 70);
    map.insert(15, 90);
    map.insert(16, 100);

    map.remove(&rdr_setup)
}

/// Read the pregenerated randomness seed from file.
pub fn rdr_read_rand_seed(num_of_users: u64, iter: usize) -> io::Result<Vec<i64>> {
    // let rand_seed_file = "/home/jethros/dev/pvn/utils/rand_number/rand.json";
    let rand_seed_file = "/tmp/udf/rand.json";
    let mut rand_vec = Vec::new();
    let file = File::open(rand_seed_file).expect("rand seed file should open read only");
    let json_data: Value = from_reader(file).expect("file should be proper JSON");

    match json_data.get("rdr") {
        Some(rdr_data) => match rdr_data.get(&num_of_users.clone().to_string()) {
            Some(setup_data) => match setup_data.get(iter.to_string()) {
                Some(data) => {
                    for x in data.as_array().unwrap() {
                        rand_vec.push(x.as_i64().unwrap());
                        // println!("RDR user: {:?}", x.as_i64().unwrap());
                    }
                }
                None => println!(
                    "No rand data for iter {:?} for users {:?}",
                    iter, num_of_users
                ),
            },
            None => println!("No rand data for users {:?}", num_of_users),
        },
        None => println!("No rdr data in the rand seed file"),
    }
    println!(
        "Fetch rand seed for num_of_users: {:?}, iter: {:?}.\nrdr users: {:?}",
        num_of_users, iter, rand_vec
    );
    Ok(rand_vec)
}

/// Create the browser for RDR proxy (user browsing).
pub fn browser_create(usr_data_dir: &String) -> Fallible<Browser> {
    // /usr/bin/chromedriver
    // /usr/bin/chromium-browser
    let timeout = Duration::new(1000, 0);

    let options = LaunchOptionsBuilder::default()
        .headless(true)
        .user_data_dir(Some(usr_data_dir.to_string()))
        // .idle_browser_timeout(timeout)
        .sandbox(false)
        .build()
        .expect("Couldn't find appropriate Chrome binary.");
    let browser = Browser::new(options)?;

    // let tab = browser.wait_for_initial_tab()?;
    // tab.set_default_timeout(std::time::Duration::from_secs(100));
    Ok(browser)
}

/// Simple user browse.
pub fn simple_user_browse(
    current_browser: &Browser,
    hostname: &str,
    _user: &i64,
) -> Fallible<(usize, u128)> {
    let now = Instant::now();
    let tab = current_browser.wait_for_initial_tab()?;
    // let tabs = current_browser.get_tabs().lock().unwrap();
    // let current_tab = tabs.iter().next().unwrap();
    let http_hostname = "http://".to_string() + &hostname;

    tab.navigate_to(&http_hostname)?;

    Ok((1, now.elapsed().as_millis()))
}

/// RDR proxy browsing scheduler.
#[allow(non_snake_case)]
#[allow(unreachable_patterns)]
pub fn rdr_scheduler(
    _pivot: &usize,
    rdr_users: &[i64],
    current_work: Vec<(u64, String, i64)>,
    browser_list: &HashMap<i64, Browser>,
) -> Option<(usize, usize, usize, usize, usize, usize)> {
    let mut num_of_ok = 0;
    let mut num_of_err = 0;
    let mut num_of_timeout = 0;
    let mut num_of_closed = 0;
    let mut num_of_visit = 0;
    let mut elapsed_time = Vec::new();

    for (milli, url, user) in current_work.into_iter() {
        println!("User {:?}: milli: {:?} url: {:?}", user, milli, url);

        if rdr_users.contains(&user) {
            match simple_user_browse(&browser_list[&user], &url, &user) {
                Ok((val, t)) => match val {
                    // ok
                    1 => {
                        num_of_ok += 1;
                        num_of_visit += 1;
                        elapsed_time.push(t as usize);
                    }
                    // err
                    2 => {
                        num_of_err += 1;
                        num_of_visit += 1;
                        elapsed_time.push(t as usize);
                    }
                    // timeout
                    3 => {
                        num_of_timeout += 1;
                        num_of_visit += 1;
                        elapsed_time.push(t as usize);
                    }
                    _ => println!("Error: unknown user browsing error type"),
                },
                Err(e) => match e {
                    ConnectionClosed => {
                        num_of_closed += 1;
                        num_of_visit += 1;
                    }
                    _ => {
                        println!(
                            "User browsing failed for url {} with user {} :{:?}",
                            url, user, e
                        );
                        num_of_err += 1;
                        num_of_visit += 1;
                    }
                },
            }
        }
    }

    let total = elapsed_time.iter().sum();

    Some((
        num_of_ok,
        num_of_err,
        num_of_timeout,
        num_of_closed,
        elapsed_time.len(),
        total,
    ))
}

/// Actual video transcoding.
///
/// We set up all the parameters for the transcoding job to happen.
pub fn transcode() {
    // let infile = "/home/jethros/dev/pvn/utils/data/tiny.y4m";
    let infile = "/tmp/udf/tiny.y4m";
    let width_height = "360x24";

    let mut infh: Box<dyn io::Read> = Box::new(File::open(infile).unwrap());
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
