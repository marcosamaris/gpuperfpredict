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
            "240 " + str(args.Device),
            "480 " + str(args.Device),
            "720 " + str(args.Device),
            "960 " + str(args.Device),
            "1200 " + str(args.Device),
            "1440 " + str(args.Device),
            "1680 " + str(args.Device),
            "1920 " + str(args.Device),
            "2160 " + str(args.Device),
            "2400 " + str(args.Device),
            "2640 " + str(args.Device),
            "2880 " + str(args.Device),
            "3120 " + str(args.Device),
            "3360 " + str(args.Device),
            "3600 " + str(args.Device),
            "3840 " + str(args.Device),
            "4080 " + str(args.Device),
            "4320 " + str(args.Device),
            "4560 " + str(args.Device),
            "4800 " + str(args.Device),
            "5040 " + str(args.Device),
            "5280 " + str(args.Device),
            "5520 " + str(args.Device),
            "5760 " + str(args.Device),
            "6000 " + str(args.Device),
            "6240 " + str(args.Device),
            "6480 " + str(args.Device),
            "6720 " + str(args.Device),
            "6960 " + str(args.Device),
            "7200 " + str(args.Device),
            "7440 " + str(args.Device),
            "7680 " + str(args.Device),
            "7920 " + str(args.Device),
            "8160 " + str(args.Device)
]

kernel = "matMul"

common.run_traces(programs, parameters, kernel, traces)
