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
if args.Traces == False  and args.Metrics == False and args.Events == False:
	traces = [" ", "--metrics all", "--events all"]

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["dotProd"]

kernel = "dotProd"

parameters = ["131072 0", "262144 0", "524288 0" ,"1048576 0" ,"2097152 0" ,"4194304 0" ,"8388608 0" ,
        "16777216 0" ,"33554432 0" ,"67108864 0" ,"134217728 0" ,"268435456 0"]

common.run_traces(programs, parameters, kernel, traces)
