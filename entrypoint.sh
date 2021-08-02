#!/usr/bin/env bash
tensorboard --logdir=/scratch &
jupyter lab --ip=0.0.0.0 --no-browser --allow-root
