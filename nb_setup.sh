#!/bin/bash
set -ex

# pull our code first
if [ -e "$HOME/dev/pvn/utils" ]; then
	cd "$HOME/dev/pvn/utils"
	git pull
else
	cd "$HOME/dev/pvn/"; git clone git@github.com:jethrosun/pvn-utils utils;
fi

if [ -e "$HOME/dev/netbricks" ]; then
	cd "$HOME/dev/netbricks"
	git pull
else
	cd "$HOME/dev/"; git clone git@github.com:jethrosun/NetBricks.git -b expr netbricks;
fi

# we will want to always reinstal Rust due to time traveral consequences
rm -rf $HOME/.rustup
rm -rf $HOME/.cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y
rustup toolchain install nightly-2021-03-15 --allow-downgrade --profile minimal --component rust-src rustfmt
source $HOME/.cargo/env


rustup default nightly-2021-03-15
rustup override set nightly-2021-03-15

"$HOME/dev/netbricks/build.sh"
printf "netbricks building done\n"
