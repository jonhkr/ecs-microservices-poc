#!/bin/bash
set -ex

script_dir=$(dirname "$0")

CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o "${script_dir}/main" "${script_dir}"