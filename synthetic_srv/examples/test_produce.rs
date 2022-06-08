extern crate faktory;
extern crate rand;

use crate::rand::Rng;
use core_affinity::CoreId;
use faktory::ConsumerBuilder;
use std::collections::HashMap;
use std::convert::TryInto;
use std::env;
use std::fs::{File, OpenOptions};
use std::io::Write;
use std::process;
use std::time::{Duration, Instant};
use std::vec;
use std::{io, thread};

fn main() {
    let fak_conn = Arc::new(Mutex::new(Producer::connect(None).unwrap()));
}
