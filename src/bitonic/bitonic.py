#!/usr/bin/python3

import imp
import subprocess

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["bitonic"]

parameters = ["32768 0","65536 0", "131072 0", "262144 0", "524288 0" ,"1048576 0" ,"2097152 0" ,"4194304 0"]

kernel = "Bitonic_Sort"

common.run_traces(programs, parameters, kernel)
