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
            "288 " + str(args.Device),
            "576 " + str(args.Device),
            "864 " + str(args.Device),
            "1152 " + str(args.Device),
            "1440 " + str(args.Device),
            "1728 " + str(args.Device),
            "2016 " + str(args.Device),
            "2304 " + str(args.Device),
            "2592 " + str(args.Device),
            "2880 " + str(args.Device),
            "3168 " + str(args.Device),
            "3456 " + str(args.Device),
            "3744 " + str(args.Device),
            "4032 " + str(args.Device),
            "4320 " + str(args.Device),
            "4608 " + str(args.Device),
            "4896 " + str(args.Device),
            "5184 " + str(args.Device),
            "5472 " + str(args.Device),
            "5760 " + str(args.Device),
            "6048 " + str(args.Device),
            "6336 " + str(args.Device),
            "6624 " + str(args.Device),
            "6912 " + str(args.Device),
            "7200 " + str(args.Device),
            "7488 " + str(args.Device),
            "7776 " + str(args.Device),
            "8064 " + str(args.Device),
            "8352 " + str(args.Device),
            "8640 " + str(args.Device),
            "8928 " + str(args.Device),
            "9216 " + str(args.Device)
]

kernel = "matMul"

common.run_traces(programs, parameters, kernel, traces)
