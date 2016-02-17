#!/usr/bin/python3

import imp
import subprocess

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["matMul_gpu", "matMul_gpu_uncoalesced",
            "matMul_gpu_sharedmem_uncoalesced", "matMul_gpu_sharedmem"]

parameters = ["256 16 0", "512 16 0","1024 16 0","2048 16 0","4096 16 0","8192 16 0"]

common.run_traces(programs, parameters)
