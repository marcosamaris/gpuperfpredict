import csv
import re
import os
import subprocess
import argparse

gpu = "Tesla"
experiment = 10                    

def run_traces(programs, parameters, kernel, traces):

    for i in range(0, experiment):
        os.system("mkdir -p ../traces/")    
        for trace in traces:
            for program in programs:
                for param in parameters:
                    cmd = "nvprof"
                    cmd += "  --unified-memory-profiling off"
                    cmd += " --normalized-time-unit ns"
                    cmd += " --print-gpu-trace "
                    cmd += " --csv " 
                    
                    size = param.split()

                    if trace == " ":
                        cmd += trace 
                        cmd += " ./" + program + " " + param 
                        cmd += " 2> Temp; cat Temp | awk '{print "+ str(size[0]) + "\",\" $0}' | tail -n +4 >>  ../logs/run_" + str(i) + "/"  + program + "-traces.csv"
                        print(cmd)
                        output = subprocess.check_output(cmd,  shell = True)
                        output = subprocess.check_output("cat ../traces/" + program + "-traces-" + str(i) + ".csv | grep " + kernel + " > ../traces/" + program + "-kernel-traces-" + str(i) + ".csv", shell = True)

                        output = subprocess.check_output("cat ../traces/" + program + "-traces-" + str(i) + ".csv | grep HtoD  > ../traces/" + program + "-HtoD-traces-" + str(i) + ".csv", shell = True)
                        output = subprocess.check_output("cat ../traces/" + program + "-traces-" + str(i) + ".csv | grep DtoH  > ../traces/" + program + "-DtoH-traces-" + str(i) + ".csv", shell = True)
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

