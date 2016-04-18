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

programs = ["quicksort"]

parameters = ["2048 0 " + str(args.Device),
                "2560 0 " + str(args.Device),
                "3072 0 " + str(args.Device),
                "3584 0 " + str(args.Device),
                "4096 0 " + str(args.Device),
                "4608 0 " + str(args.Device),
                "5120 0 " + str(args.Device),
                "5632 0 " + str(args.Device),
                "6144 0 " + str(args.Device),
                "6656 0 " + str(args.Device),
                "7168 0 " + str(args.Device),
                "7680 0 " + str(args.Device),
                "8192 0 " + str(args.Device),
                "8704 0 " + str(args.Device),
                "9216 0 " + str(args.Device),
                "9728 0 " + str(args.Device),
                "10240 0 " + str(args.Device),
                "10752 0 " + str(args.Device),
                "11264 0 " + str(args.Device),
                "11776 0 " + str(args.Device),
                "12288 0 " + str(args.Device),
                "12800 0 " + str(args.Device),
                "13312 0 " + str(args.Device),
                "13824 0 " + str(args.Device),
                "14336 0 " + str(args.Device),
                "14848 0 " + str(args.Device),
                "15360 0 " + str(args.Device),
                "15872 0 " + str(args.Device),
                "16384 0 " + str(args.Device),
                "16896 0 " + str(args.Device),
                "17408 0 " + str(args.Device),
                "17920 0 " + str(args.Device),
                "18432 0 " + str(args.Device),
                "18944 0 " + str(args.Device),
                "19456 0 " + str(args.Device),
                "19968 0 " + str(args.Device),
                "20480 0 " + str(args.Device),
                "20992 0 " + str(args.Device),
                "21504 0 " + str(args.Device),
                "22016 0 " + str(args.Device),
                "22528 0 " + str(args.Device),
                "23040 0 " + str(args.Device),
                "23552 0 " + str(args.Device),
                "24064 0 " + str(args.Device),
                "24576 0 " + str(args.Device),
                "25088 0 " + str(args.Device),
                "25600 0 " + str(args.Device),
                "26112 0 " + str(args.Device),
                "26624 0 " + str(args.Device),
                "27136 0 " + str(args.Device),
                "27648 0 " + str(args.Device),
                "28160 0 " + str(args.Device),
                "28672 0 " + str(args.Device),
                "29184 0 " + str(args.Device),
                "29696 0 " + str(args.Device),
                "30208 0 " + str(args.Device),
                "30720 0 " + str(args.Device),
                "31232 0 " + str(args.Device),
                "31744 0 " + str(args.Device),
                "32256 0 " + str(args.Device),
                "32768 0 " + str(args.Device),
                "33280 0 " + str(args.Device),
                "33792 0 " + str(args.Device),
                "34304 0 " + str(args.Device),
                "34816 0 " + str(args.Device),
                "35328 0 " + str(args.Device),
                "35840 0 " + str(args.Device),
                "36352 0 " + str(args.Device),
                "36864 0 " + str(args.Device),
                "37376 0 " + str(args.Device),
                "37888 0 " + str(args.Device),
                "38400 0 " + str(args.Device),
                "38912 0 " + str(args.Device),
                "39424 0 " + str(args.Device),
                "39936 0 " + str(args.Device),
                "40448 0 " + str(args.Device),
                "40960 0 " + str(args.Device),
                "41472 0 " + str(args.Device),
                "41984 0 " + str(args.Device),
                "42496 0 " + str(args.Device),
                "43008 0 " + str(args.Device),
                "43520 0 " + str(args.Device),
                "44032 0 " + str(args.Device),
                "44544 0 " + str(args.Device),
                "45056 0 " + str(args.Device),
                "45568 0 " + str(args.Device),
                "46080 0 " + str(args.Device),
                "46592 0 " + str(args.Device),
                "47104 0 " + str(args.Device),
                "47616 0 " + str(args.Device),
                "48128 0 " + str(args.Device),
                "48640 0 " + str(args.Device),
                "49152 0 " + str(args.Device),
                "49664 0 " + str(args.Device),
                "50176 0 " + str(args.Device),
                "50688 0 " + str(args.Device),
                "51200 0 " + str(args.Device),
                "51712 0 " + str(args.Device),
                "52224 0 " + str(args.Device),
                "52736 0 " + str(args.Device),
                "53248 0 " + str(args.Device),
                "53760 0 " + str(args.Device),
                "54272 0 " + str(args.Device),
                "54784 0 " + str(args.Device),
                "55296 0 " + str(args.Device),
                "55808 0 " + str(args.Device),
                "56320 0 " + str(args.Device),
                "56832 0 " + str(args.Device),
                "57344 0 " + str(args.Device),
                "57856 0 " + str(args.Device),
                "58368 0 " + str(args.Device),
                "58880 0 " + str(args.Device),
                "59392 0 " + str(args.Device),
                "59904 0 " + str(args.Device),
                "60416 0 " + str(args.Device),
                "60928 0 " + str(args.Device),
                "61440 0 " + str(args.Device),
                "61952 0 " + str(args.Device),
                "62464 0 " + str(args.Device),
                "62976 0 " + str(args.Device),
                "63488 0 " + str(args.Device),
                "64000 0 " + str(args.Device),
                "64512 0 " + str(args.Device),
                "65024 0 " + str(args.Device),
                "65536 0 " + str(args.Device)]

kernel = "quicksort"

common.run_traces(programs, parameters, kernel, traces)
