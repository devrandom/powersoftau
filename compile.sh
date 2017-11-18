#!/bin/sh

set -ex

#$HOME/opt/bin/cargo clean
#$HOME/opt/bin/cargo build -p typenum

rm -rf target

#RUST_VERSION=1.13.0
#RUST_VERSION=1.10.0
RUST_VERSION=2016-07-07
RUSTC="$HOME/opt/rust-$RUST_VERSION/bin/rustc"
#RUSTC=rustc
ARGS="--cap-lints allow -C debuginfo=2 --emit=dep-info,link"
DEPS_OUT_DIR="/home/vagrant/src/powersoftau/target/debug/deps"
DEPS_ARGS="--out-dir $DEPS_OUT_DIR -L dependency=/home/vagrant/src/powersoftau/target/debug/deps"
#DEPS_BASE="/home/vagrant/.cargo/registry/src/github.com-1ecc6299db9ec823"
DEPS_BASE="/home/vagrant/src/powersoftau/vendor"
mkdir -p target/debug/deps

$RUSTC --crate-name libc $DEPS_BASE/libc-0.2.32/src/lib.rs --crate-type lib --cfg 'feature="default"' --cfg 'feature="use_std"' $DEPS_ARGS $ARGS
$RUSTC --crate-name constant_time_eq $DEPS_BASE/constant_time_eq-0.1.3/src/lib.rs --crate-type lib $DEPS_ARGS $ARGS
$RUSTC --crate-name build_script_main $DEPS_BASE/typenum-1.9.0/build/main.rs --crate-type bin $DEPS_ARGS $ARGS
#OUT_DIR="$PWD/target/debug/build/typenum-b201dc5f3aa9a2f3/out" /home/vagrant/src/powersoftau/target/debug/build/typenum-1d8f660cc0eb5a26/build-script-main
TYPENUM_OUTDIR="$PWD/target/debug/build/typenum/out"
mkdir -p "$TYPENUM_OUTDIR"
cp typenum/*.rs "$TYPENUM_OUTDIR"
OUT_DIR="$TYPENUM_OUTDIR" $RUSTC --crate-name typenum $DEPS_BASE/typenum-1.9.0/src/lib.rs --crate-type lib $DEPS_ARGS $ARGS
$RUSTC --crate-name byte_tools $DEPS_BASE/byte-tools-0.2.0/src/lib.rs --crate-type lib $DEPS_ARGS $ARGS
$RUSTC --crate-name nodrop $DEPS_BASE/nodrop-0.1.12/src/lib.rs --crate-type lib $DEPS_ARGS $ARGS
$RUSTC --crate-name byteorder $DEPS_BASE/byteorder-1.1.0/src/lib.rs --crate-type lib --cfg 'feature="default"' --cfg 'feature="std"' $DEPS_ARGS $ARGS
$RUSTC --crate-name crossbeam $DEPS_BASE/crossbeam-0.3.0/src/lib.rs --crate-type lib $DEPS_ARGS $ARGS
$RUSTC --crate-name rand $DEPS_BASE/rand-0.3.17/src/lib.rs --crate-type lib $DEPS_ARGS --extern libc=$DEPS_OUT_DIR/liblibc.rlib $ARGS
$RUSTC --crate-name num_cpus $DEPS_BASE/num_cpus-1.7.0/src/lib.rs --crate-type lib $DEPS_ARGS --extern libc=$DEPS_OUT_DIR/liblibc.rlib $ARGS
$RUSTC --crate-name generic_array $DEPS_BASE/generic-array-0.8.3/src/lib.rs --crate-type lib $DEPS_ARGS --extern nodrop=$DEPS_OUT_DIR/libnodrop.rlib --extern typenum=$DEPS_OUT_DIR/libtypenum.rlib $ARGS
$RUSTC --crate-name digest $DEPS_BASE/digest-0.6.2/src/lib.rs --crate-type lib $DEPS_ARGS --extern generic_array=$DEPS_OUT_DIR/libgeneric_array.rlib $ARGS
$RUSTC --crate-name crypto_mac $DEPS_BASE/crypto-mac-0.4.0/src/lib.rs --crate-type lib $DEPS_ARGS --extern generic_array=$DEPS_OUT_DIR/libgeneric_array.rlib --extern constant_time_eq=$DEPS_OUT_DIR/libconstant_time_eq.rlib $ARGS
$RUSTC --crate-name blake2 $DEPS_BASE/blake2-0.6.1/src/lib.rs --crate-type lib $DEPS_ARGS --extern digest=$DEPS_OUT_DIR/libdigest.rlib --extern generic_array=$DEPS_OUT_DIR/libgeneric_array.rlib --extern crypto_mac=$DEPS_OUT_DIR/libcrypto_mac.rlib --extern byte_tools=$DEPS_OUT_DIR/libbyte_tools.rlib $ARGS

$RUSTC --crate-name pairing $DEPS_BASE/pairing-0.13.0/src/lib.rs --crate-type lib --cfg 'feature="default"' $DEPS_ARGS --extern rand=$DEPS_OUT_DIR/librand.rlib --extern byteorder=$DEPS_OUT_DIR/libbyteorder.rlib $ARGS

$RUSTC --crate-name powersoftau src/lib.rs --crate-type lib $DEPS_ARGS --extern rand=$DEPS_OUT_DIR/librand.rlib --extern pairing=$DEPS_OUT_DIR/libpairing.rlib --extern crossbeam=$DEPS_OUT_DIR/libcrossbeam.rlib --extern generic_array=$DEPS_OUT_DIR/libgeneric_array.rlib --extern byteorder=$DEPS_OUT_DIR/libbyteorder.rlib --extern num_cpus=$DEPS_OUT_DIR/libnum_cpus.rlib --extern blake2=$DEPS_OUT_DIR/libblake2.rlib --extern typenum=$DEPS_OUT_DIR/libtypenum.rlib

$RUSTC --crate-name new src/bin/new.rs --crate-type bin $DEPS_ARGS --extern rand=$DEPS_OUT_DIR/librand.rlib --extern pairing=$DEPS_OUT_DIR/libpairing.rlib --extern crossbeam=$DEPS_OUT_DIR/libcrossbeam.rlib --extern generic_array=$DEPS_OUT_DIR/libgeneric_array.rlib --extern byteorder=$DEPS_OUT_DIR/libbyteorder.rlib --extern num_cpus=$DEPS_OUT_DIR/libnum_cpus.rlib --extern blake2=$DEPS_OUT_DIR/libblake2.rlib --extern typenum=$DEPS_OUT_DIR/libtypenum.rlib --extern powersoftau=$DEPS_OUT_DIR/libpowersoftau.rlib

$RUSTC --crate-name verify_transform src/bin/verify_transform.rs --crate-type bin $DEPS_ARGS --extern rand=$DEPS_OUT_DIR/librand.rlib --extern pairing=$DEPS_OUT_DIR/libpairing.rlib --extern crossbeam=$DEPS_OUT_DIR/libcrossbeam.rlib --extern generic_array=$DEPS_OUT_DIR/libgeneric_array.rlib --extern byteorder=$DEPS_OUT_DIR/libbyteorder.rlib --extern num_cpus=$DEPS_OUT_DIR/libnum_cpus.rlib --extern blake2=$DEPS_OUT_DIR/libblake2.rlib --extern typenum=$DEPS_OUT_DIR/libtypenum.rlib --extern powersoftau=$DEPS_OUT_DIR/libpowersoftau.rlib

$RUSTC --crate-name compute src/bin/compute.rs --crate-type bin $DEPS_ARGS --extern rand=$DEPS_OUT_DIR/librand.rlib --extern pairing=$DEPS_OUT_DIR/libpairing.rlib --extern crossbeam=$DEPS_OUT_DIR/libcrossbeam.rlib --extern generic_array=$DEPS_OUT_DIR/libgeneric_array.rlib --extern byteorder=$DEPS_OUT_DIR/libbyteorder.rlib --extern num_cpus=$DEPS_OUT_DIR/libnum_cpus.rlib --extern blake2=$DEPS_OUT_DIR/libblake2.rlib --extern typenum=$DEPS_OUT_DIR/libtypenum.rlib --extern powersoftau=$DEPS_OUT_DIR/libpowersoftau.rlib
