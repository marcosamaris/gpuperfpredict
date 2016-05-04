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

programs = ["vectorAdd"]

parameters = ["131072 " + str(args.Device),
		"262144 " + str(args.Device),
		"524288 " + str(args.Device),
		"1048576 " + str(args.Device),
		"2097152 " + str(args.Device),
		"4194304 " + str(args.Device),
		"8388608 " + str(args.Device),
		"12582912 " + str(args.Device),
		"16777216 " + str(args.Device),
		"20971520 " + str(args.Device),
		"25165824 " + str(args.Device),
		"29360128 " + str(args.Device),
		"33554432 " + str(args.Device),
		"37748736 " + str(args.Device),
		"41943040 " + str(args.Device),
		"46137344 " + str(args.Device),
		"50331648 " + str(args.Device),
		"54525952 " + str(args.Device),
		"58720256 " + str(args.Device),
		"62914560 " + str(args.Device),
		"67108864 " + str(args.Device),
		"71303168 " + str(args.Device),
		"75497472 " + str(args.Device),
		"79691776 " + str(args.Device),
		"83886080 " + str(args.Device),
		"88080384 " + str(args.Device),
		"92274688 " + str(args.Device),
		"96468992 " + str(args.Device),
		"100663296 " + str(args.Device),
		"104857600 " + str(args.Device),
		"109051904 " + str(args.Device),
		"113246208 " + str(args.Device),
		"117440512 " + str(args.Device),
		"121634816 " + str(args.Device),
		"125829120 " + str(args.Device),
		"130023424 " + str(args.Device),
		"134217728 " + str(args.Device),
		"138412032 " + str(args.Device),
		"142606336 " + str(args.Device),
		"146800640 " + str(args.Device),
		"150994944 " + str(args.Device),
		"155189248 " + str(args.Device),
		"159383552 " + str(args.Device),
		"163577856 " + str(args.Device),
		"167772160 " + str(args.Device),
		"171966464 " + str(args.Device),
		"176160768 " + str(args.Device),
		"180355072 " + str(args.Device),
		"184549376 " + str(args.Device),
		"188743680 " + str(args.Device),
		"192937984 " + str(args.Device),
		"197132288 " + str(args.Device),
		"201326592 " + str(args.Device),
		"205520896 " + str(args.Device),
		"209715200 " + str(args.Device),
		"213909504 " + str(args.Device),
		"218103808 " + str(args.Device),
		"222298112 " + str(args.Device),
		"226492416 " + str(args.Device),
		"230686720 " + str(args.Device),
		"234881024 " + str(args.Device),
		"239075328 " + str(args.Device),
		"243269632 " + str(args.Device),
		"247463936 " + str(args.Device),
		"251658240 " + str(args.Device),
		"255852544 " + str(args.Device),
		"260046848 " + str(args.Device),
		"264241152 " + str(args.Device),
		"268435456 " + str(args.Device) ]

kernel = "vectorAdd"

common.run_traces(programs, parameters, kernel, traces)
