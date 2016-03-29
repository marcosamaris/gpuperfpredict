import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

from pandas import DataFrame

#PLAN: get data of 1 GPU first with and without L1 cache compute 3 capability
#Add GPU data manually ( automatically would be too headache for its efficiency )

#Compute Version
computeVersion = 3

# to control which GPU data to use
gpus = pd.Series(["Tesla-K40","Tesla-k40-UsingL1"]);

#List of applications( to be continued)
applications = pd.Series(["bitonic","dotProd","matMul_gpu","matMul_gpu_sharedmem","matMul_gpu_sharedmem_uncoalesced",
                          "matMul_gpu_uncoalesced","matrix_sum_coalesced","matrix_sum_normal","quicksort"]);

#deviceQueryPath=gpuPath[0] + gpus
#with open(fname) as f:
#    content = f.readlines()

deviceQueryDF = pd.DataFrame({ 'gpu_name' : gpus,
			       'compute_version': np.array([computeVersion,computeVersion]),
			       'num_of_cores': np.array([2880,2880],dtype='int32'),
	                       'max_clock_rate' : np.array([745,745],dtype='int32'), #in Mhz
			       'l1_cache_used': np.array([0,1])})

deviceQueryDF.to_csv('deviceData.csv');

#create a dataframe with zero rows, just the colums labels
eventsHeaderDF = pd.read_csv("../data/eventsNames-3X.csv");

metricsHeaderDF = pd.read_csv("../data/metricsNames-3X.csv");

tracesHeaderDF = pd.read_csv("../data/tracesNames-3X.csv");

#Contians folder paths for GPUs
gpuPath=pd.Series([""]);

## Get traces data: need to extract running time .. 
#Construct folder paths and search for traces in each GPU directory
for i in range(0,gpus.size):
	gpuPath[i] = "../data/"+gpus[i]+"/run_0/";
	#print(gpuPath);

	for file in os.listdir(gpuPath[i]):
    		if file.endswith("-kernel-traces.csv"):
			fullPath = gpuPath[i] + file;
        		print(fullPath);
			tempDF = pd.read_csv(fullPath,header=None, names = tracesHeaderDF.columns );
			tracesHeaderDF = tracesHeaderDF.append(tempDF);

#Select only duration
tracesHeaderDF = tracesHeaderDF[['Duration']];
#tracesHeaderDF = tracesHeaderDF.ix[:,'Duration':'Duration']
tracesHeaderDF.to_csv("traces.csv");
#about 6000 samples, due to bitonic samples

#Get events data
#What do I need from events exactly ?
for i in range(0,gpus.size):
	gpuPath[i] = "../data/"+gpus[i]+"/run_0/";

	for file in os.listdir(gpuPath[i]):
    		if file.endswith("-events.csv"):
			fullPath = gpuPath[i] + file;
        		print(fullPath);
			tempDF = pd.read_csv(fullPath,header=None, names = eventsHeaderDF.columns );
			#print(tempDF);
			eventsHeaderDF = eventsHeaderDF.append(tempDF);
			
eventsHeaderDF.to_csv("events.csv");


#Get Metrics data
#What do I need from metrics exactly ?
for i in range(0,gpus.size):
	gpuPath[i] = "../data/"+gpus[i]+"/run_0/";

	for file in os.listdir(gpuPath[i]):
    		if file.endswith("-metrics.csv"):
			fullPath = gpuPath[i] + file;
        		print(fullPath);
			tempDF = pd.read_csv(fullPath,header=None, names = metricsHeaderDF.columns );
			#print(tempDF);
			metricsHeaderDF = metricsHeaderDF.append(tempDF);
			
metricsHeaderDF.to_csv("metrics.csv");

#Metrics.csv, events.csv and traces.csv are different in number of samples ... should be equal
# exclude bitonic for now ?
#How to get number of threads ? is it from traces.csv ? gridX * gridY * gridZ * blockX * blockY * blockZ ?

##################################################
# To create dummy last dataframe
##################################################


