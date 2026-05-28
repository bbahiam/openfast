#!/bin/bash +x

directory=$1

find $directory -name '*.fst' -execdir sbatch --job-name={} --ntasks 1 --mem=1G $PWD/run_case.sh {} \;
