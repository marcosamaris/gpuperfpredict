#!/usr/bin/python3

import imp
import subprocess

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["vectorAdd"]

parameters = ["131072", "262144", "524288" ,"1048576" ,"2097152" ,"4194304" ,"8388608"]

kernel = "VecAdd"

common.run_traces(programs, parameters, kernel)
