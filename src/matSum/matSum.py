#!/usr/bin/python3

import imp
common = imp.load_source("common", "../common/common.py")

programs = ["matrix_sum_normal", "matrix_sum_coalesced"]

parameters = ["512 0", "1024 0","2048 0","4096 0","8192 0","16384 0"]

common.run_traces(programs, parameters)
