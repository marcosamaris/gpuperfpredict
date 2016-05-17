import csv
import re
import os
import subprocess
import argparse

gpu = "Tesla"
experiment = 1                    

def run_traces(programs, parameters, kernel, traces):

    for i in range(0, experiment):
        os.system("mkdir -p ../logs/run_" + str(i))    
        for trace in traces:
            for program in programs:
                for param in parameters:
                    cmd = "nvprof"
                    cmd += " --normalized-time-unit s"
                    cmd += " --print-gpu-trace "
                    cmd += " --csv " 
                    
                    size = param.split()

                    if trace == " ":
                        cmd += trace 
                        cmd += " ./" + program + " " + param 
                        cmd += " 2> Temp; cat Temp | awk '{print "+ str(size[0]) + "\",\" $0}' | tail -n +4 >>  ../logs/run_" + str(i) + "/"  + program + "-traces.csv"
                        print(cmd)
                        output = subprocess.check_output(cmd,  shell = True)
                        output = subprocess.check_output("cat ../logs/run_" + str(i) + "/" + program + "-traces.csv | grep " + kernel + " > ../logs/run_" + str(i) + "/" + program + "-kernel-traces.csv", shell = True)
                        #output = subprocess.check_output("cat ../logs/run_" + str(i) + "/" + program + "-traces.csv | grep HtoD > ../logs/run_" + str(i) + "/" + program + "-HtoD-traces.csv", shell = True)
                        #output = subprocess.check_output("cat ../logs/run_" + str(i) + "/" + program + "-traces.csv | grep DtoH > ../logs/run_" + str(i) + "/" + program + "-DtoH-traces.csv", shell = True)
                    elif trace == "--metrics all":
                        cmd += trace 
                        cmd += " ./" + program + " " + param 
                        cmd += " 2> Temp; cat Temp | awk '{print "+ str(size[0]) + "\",\" $0}' | grep '" + gpu + "' >> ../logs/run_" + str(i) + "/" + program + "-metrics.csv"
                        print(cmd)
                        output = subprocess.check_output(cmd,  shell = True)#, stderr=subprocess.STDOUT)
                    elif trace == "--events all":
                        cmd += trace
                        cmd += " ./" + program + " " + param 
                        cmd += " 2> Temp; cat Temp | awk '{print "+ str(size[0]) + "\",\" $0}' | grep '" + gpu + "' >> ../logs/run_" + str(i) + "/" + program + "-events.csv"
                        print(cmd)
                        output = subprocess.check_output(cmd,  shell = True)

