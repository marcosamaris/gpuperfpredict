#!/usr/bin/python3

import imp
import subprocess
import argparse

argparser = argparse.ArgumentParser()

argparser.add_argument( "--Traces", type = bool, default=False, help = "Run Traces of the Benchmarks.")
argparser.add_argument( "--Metrics", type = bool, default=False, help = "Runs Metrics of the Benchmarks.")
argparser.add_argument( "--Events", type = bool, default=False, help  = "Runs Eents of the Benchmarks.")

args = argparser.parse_args()
					
if args.Traces == True:
	traces = [" "]
if args.Metrics == True:
	traces = ["--metrics all"]
if args.Events == True:
	traces = ["--events all"]
if args.Traces == True  and args.Metrics == True and args.Events == False:
	traces = [" ", "--metrics all", "--events all"]

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["matMul_gpu", "matMul_gpu_uncoalesced",
            "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem"]

parameters = ["256 16 0", "512 16 0","1024 16 0","2048 16 0","4096 16 0","8192 16 0"]

kernel = "matMul"

common.run_traces(programs, parameters, kernel, traces)
