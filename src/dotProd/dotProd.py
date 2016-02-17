#!/usr/bin/python3

import imp
import subprocess

common = imp.load_source("common", "../common/common.py")

subprocess.check_output("rm -f *.csv",  shell = True)

programs = ["dotProd"]

parameters = ["131072 0", "262144 0", "524288 0" ,"1048576 0" ,"2097152 0" ,"4194304 0" ,"8388608 0" ,
        "16777216 0" ,"33554432 0" ,"67108864 0" ,"134217728 0" ,"268435456 0"]

common.run_traces(programs, parameters)
