#!/bin/bash
set -ex

current_dir=$(pwd)
script_dir=$(dirname "$0")

cd "${script_dir}"

./gradlew test assemble --parallel

mkdir -p build/dependency && (cd build/dependency; jar -xf ../libs/*.jar)

cd "${current_dir}"