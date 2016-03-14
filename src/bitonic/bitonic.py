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

programs = ["bitonic"]

parameters = ["32768 0 " + str(args.Device),"65536 0 " + str(args.Device), "131072 0 " + str(args.Device), "262144 0 " + str(args.Device), "524288 0 " + str(args.Device), "1048576 0 " + str(args.Device),"2097152 0 " + str(args.Device),"4194304 0 " + str(args.Device)]

kernel = "Bitonic_Sort"

common.run_traces(programs, parameters, kernel,traces)
