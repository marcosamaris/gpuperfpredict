#!/usr/bin/python

import imp
import subprocess
import argparse

argparser = argparse.ArgumentParser()

argparser.add_argument( "--Traces", type = bool, default=False, help = "Run Traces of the Benchmarks.")
argparser.add_argument( "--Metrics", type = bool, default=False, help = "Runs Metrics of the Benchmarks.")
argparser.add_argument( "--Events", type = bool, default=False, help  = "Runs Eents of the Benchmarks.")
argparser.add_argument( "--Device", type = int, default=0, help  = "Device where the experiment will be executed.")

args = argparser.parse_args()
					
if args.Traces == True:
	traces = [" "]
if args.Metrics == True:
	traces = ["--metrics all"]
if args.Events == True:
	traces = ["--events all"]
if args.Traces == False  and args.Metrics == False and args.Events == False:
	traces = [" ", "--metrics all", "--events all"]

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["matMul_gpu", "matMul_gpu_uncoalesced",
            "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem"]

parameters = ["128 16 0 " + str(args.Device), "256 16 0 " + str(args.Device), "512 16 0 " + str(args.Device),"1024 16 0 " + str(args.Device),"2048 16 0 " + str(args.Device),"4096 16 0 " + str(args.Device),"8192 16 0 " + str(args.Device)]

kernel = "matMul"

common.run_traces(programs, parameters, kernel, traces)
