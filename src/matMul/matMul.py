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

programs = [ "matMul_gpu_sharedmem"]

parameters = [
            "252 " + str(args.Device),
            "504 " + str(args.Device),
            "756 " + str(args.Device),
            "1008 " + str(args.Device),
            "1260 " + str(args.Device),
            "1512 " + str(args.Device),
            "1764 " + str(args.Device),
            "2016 " + str(args.Device),
            "2268 " + str(args.Device),
            "2520 " + str(args.Device),
            "2772 " + str(args.Device),
            "3024 " + str(args.Device),
            "3276 " + str(args.Device),
            "3528 " + str(args.Device),
            "3780 " + str(args.Device),
            "4032 " + str(args.Device),
            "4284 " + str(args.Device),
            "4536 " + str(args.Device),
            "4788 " + str(args.Device),
            "5040 " + str(args.Device),
            "5292 " + str(args.Device),
            "5544 " + str(args.Device),
            "5796 " + str(args.Device),
            "6048 " + str(args.Device),
            "6300 " + str(args.Device),
            "6552 " + str(args.Device),
            "6804 " + str(args.Device),
            "7056 " + str(args.Device),
            "7308 " + str(args.Device),
            "7560 " + str(args.Device),
            "7812 " + str(args.Device),
            "8064 " + str(args.Device)]

kernel = "matMul"

common.run_traces(programs, parameters, kernel, traces)
