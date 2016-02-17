#!/usr/bin/python3

import csv
import re
import os
import statistics
import subprocess


def run_traces(filename, programs, sizes, device_id=0):
    regex = re.compile("Total elapsed time: (.*)")
    fieldnames = ["PROGRAM", "N", "REPETITIONS", "MEAN", "STDEV"]

    with open("./" + filename, mode="a") as csv_file:
        csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        csv_writer.writeheader()
        traces = [" ", "--metrics all", "--events all"]
        for trace in traces:
            

            for program in programs:
                for n in sizes:
                    cmd = "nvprof"
                    cmd += " --normalized-time-unit " + "s"
                    cmd += " --print-gpu-trace "
                    if trace == " ":
                        cmd += trace
                    elif trace == "--metrics all":
                        cmd += trace
                    else:
                        cmd += trace

                    cmd += " --csv " 
                    cmd += " ./"
                    cmd += program
                    cmd += " " + str(n)
                    cmd += " " + str(device_id)
                    if trace == " ":
                        cmd += " 2>> ./traces.csv"
                    elif trace == "--metrics all":
                        cmd += " 2>> ./metrics.csv"
                    else:
                        cmd += " 2>> ./events.csv"

                    output = subprocess.check_output(cmd,  shell = True)#, stderr=subprocess.STDOUT)
                    #print("Primeiro{}".format(output))
    

