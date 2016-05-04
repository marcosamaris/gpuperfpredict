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

programs = ["subSeqMax"]

parameters = [	"131072 0 " + str(args.Device),
		"262144 0 " + str(args.Device),
		"524288 0 " + str(args.Device),
		"1048576 0 " + str(args.Device),
		"2097152 0 " + str(args.Device),
		"4194304 0 " + str(args.Device),
		"8388608 0 " + str(args.Device),
		"12582912 0 " + str(args.Device),
		"16777216 0 " + str(args.Device),
		"20971520 0 " + str(args.Device),
		"25165824 0 " + str(args.Device),
		"29360128 0 " + str(args.Device),
		"33554432 0 " + str(args.Device),
		"37748736 0 " + str(args.Device),
		"41943040 0 " + str(args.Device),
		"46137344 0 " + str(args.Device),
		"50331648 0 " + str(args.Device),
		"54525952 0 " + str(args.Device),
		"58720256 0 " + str(args.Device),
		"62914560 0 " + str(args.Device),
		"67108864 0 " + str(args.Device),
		"71303168 0 " + str(args.Device),
		"75497472 0 " + str(args.Device),
		"79691776 0 " + str(args.Device),
		"83886080 0 " + str(args.Device),
		"88080384 0 " + str(args.Device),
		"92274688 0 " + str(args.Device),
		"96468992 0 " + str(args.Device),
		"100663296 0 " + str(args.Device),
		"104857600 0 " + str(args.Device),
		"109051904 0 " + str(args.Device),
		"113246208 0 " + str(args.Device),
		"117440512 0 " + str(args.Device),
		"121634816 0 " + str(args.Device),
		"125829120 0 " + str(args.Device),
		"130023424 0 " + str(args.Device),
		"134217728 0 " + str(args.Device),
		"138412032 0 " + str(args.Device),
		"142606336 0 " + str(args.Device),
		"146800640 0 " + str(args.Device),
		"150994944 0 " + str(args.Device),
		"155189248 0 " + str(args.Device),
		"159383552 0 " + str(args.Device),
		"163577856 0 " + str(args.Device),
		"167772160 0 " + str(args.Device),
		"171966464 0 " + str(args.Device),
		"176160768 0 " + str(args.Device),
		"180355072 0 " + str(args.Device),
		"184549376 0 " + str(args.Device),
		"188743680 0 " + str(args.Device),
		"192937984 0 " + str(args.Device),
		"197132288 0 " + str(args.Device),
		"201326592 0 " + str(args.Device),
		"205520896 0 " + str(args.Device),
		"209715200 0 " + str(args.Device),
		"213909504 0 " + str(args.Device),
		"218103808 0 " + str(args.Device),
		"222298112 0 " + str(args.Device),
		"226492416 0 " + str(args.Device),
		"230686720 0 " + str(args.Device),
		"234881024 0 " + str(args.Device),
		"239075328 0 " + str(args.Device),
		"243269632 0 " + str(args.Device),
		"247463936 0 " + str(args.Device),
		"251658240 0 " + str(args.Device),
		"255852544 0 " + str(args.Device),
		"260046848 0 " + str(args.Device),
		"264241152 0 " + str(args.Device),
		"268435456 0 " + str(args.Device)]

kernel = "subSeqMax"

common.run_traces(programs, parameters, kernel, traces)
