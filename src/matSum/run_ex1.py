#!/usr/bin/python3

import imp
common = imp.load_source("common", "../common/common.py")

result_file = "results_ex1.csv"
programs = ["matrix_sum_normal", "matrix_sum_coalesced"]
matrix_sizes = [256, 512, 1024, 2048, 4096, 8192]
device_id = 0
repetitions = 3

common.run_traces(result_file, programs, matrix_sizes, device_id)
