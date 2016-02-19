#!/usr/bin/python3

import imp
import subprocess

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["matrix_sum_normal", "matrix_sum_coalesced"]

parameters = ["256 16 0", "512 16 0", "1024 16 0","2048 16 0","4096 16 0","8192 16 0"]

kernel = "matSum"

common.run_traces(programs, parameters, kernel)
