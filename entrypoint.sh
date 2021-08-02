#!/usr/bin/env bash
# Alias for SGWS
set -e

sgws() {
	CMD="aws ${@:1} --endpoint-url https://s3.imk-ifu.kit.edu:8082"
	echo "Executing \"${CMD}\""
	eval ${CMD}
}
export -f sgws

tensorboard --logdir=/scratch &
jupyter lab --ip=0.0.0.0 --no-browser --allow-root
