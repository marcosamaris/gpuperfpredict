#!/usr/bin/python3

import csv
import re
import os
import subprocess
import argparse

gpu = "Tesla"                    

def run_traces(programs, parameters, kernel, traces):
    
    for trace in traces:
        for program in programs:
            for param in parameters:
                cmd = "nvprof"
                cmd += " --normalized-time-unit s"
                cmd += " --print-gpu-trace "
                if trace == " ":
                    cmd += trace
                elif trace == "--metrics all":
                    cmd += trace
                elif trace == "--events all":
                    cmd += trace

                cmd += " --csv " 
                cmd += " ./"
                cmd += program
                cmd += " " + param  
                if trace == " ":
                    cmd += " 2> Temp; cat Temp | tail -n +4 >>  ../logs/" + program + "-traces.csv"
                elif trace == "--metrics all":
                    cmd += " 2> Temp; cat Temp | grep '" + gpu + "' >> ../logs/" + program + "-metrics.csv"
                elif trace == "--events all":
                    cmd += " 2> Temp; cat Temp | grep '" + gpu + "' >> ../logs/" + program + "-events.csv"

                output = subprocess.check_output(cmd,  shell = True)#, stderr=subprocess.STDOUT)
            if trace == " ":
                output = subprocess.check_output("cat ../logs/" + program + "-traces.csv | grep " + kernel + " > ../logs/" + program + "-kernel-traces.csv", shell = True)            
                output = subprocess.check_output("cat ../logs/" + program + "-traces.csv | grep HtoD > ../logs/" + program + "-HtoD-traces.csv", shell = True)
                output = subprocess.check_output("cat ../logs/" + program + "-traces.csv | grep DtoH > ../logs/" + program + "-DtoH-traces.csv", shell = True)


