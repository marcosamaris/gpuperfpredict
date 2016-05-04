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

programs = ["matrix_sum_normal", "matrix_sum_coalesced"]

parameters = ["256 " + str(args.Device),
            "512 " + str(args.Device),
            "768 " + str(args.Device),
            "1024 " + str(args.Device),
            "1280 " + str(args.Device),
            "1536 " + str(args.Device),
            "1792 " + str(args.Device),
            "2048 " + str(args.Device),
            "2304 " + str(args.Device),
            "2560 " + str(args.Device),
            "2816 " + str(args.Device),
            "3072 " + str(args.Device),
            "3328 " + str(args.Device),
            "3584 " + str(args.Device),
            "3840 " + str(args.Device),
            "4096 " + str(args.Device),
            "4352 " + str(args.Device),
            "4608 " + str(args.Device),
            "4864 " + str(args.Device),
            "5120 " + str(args.Device),
            "5376 " + str(args.Device),
            "5632 " + str(args.Device),
            "5888 " + str(args.Device),
            "6144 " + str(args.Device),
            "6400 " + str(args.Device),
            "6656 " + str(args.Device),
            "6912 " + str(args.Device),
            "7168 " + str(args.Device),
            "7424 " + str(args.Device),
            "7680 " + str(args.Device),
            "7936 " + str(args.Device),
            "8192 " + str(args.Device)]

kernel = "matSum"

common.run_traces(programs, parameters, kernel, traces)
