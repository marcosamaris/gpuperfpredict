#!/usr/bin/python3

import imp
common = imp.load_source("common", "../common/common.py")

programs = ["vectorAdd"]

parameters = ["131072", "262144", "524288" ,"1048576" ,"2097152" ,"4194304" ,"8388608"]

common.run_traces(programs, parameters)
