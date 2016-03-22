import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from pandas import DataFrame

#PLAN: get data of 1 GPU first with and without L1 cache compute 3 capability
#Add GPU data manually 

# to control which GPU data to use
gpus = pd.Series(["Tesla-K40","Tesla-k40-UsingL1"]);

#Contians folder paths for GPUs
gpuPath=pd.Series([""]);

#Construct folder paths
for i in range(0,gpus.size):
	gpuPath[i] = "../data/"+gpus[i];

#print(gpuPath);

#deviceQueryPath=gpuPath[0] + gpus
#with open(fname) as f:
#    content = f.readlines()

deviceQueryDF = pd.DataFrame({ 'gpu_name' : pd.Categorical(["Tesla-K40","Tesla-k40-UsingL1"]),
			       'compute_version': np.array([3,3]),
			       'num_of_cores': np.array([2880,2880],dtype='int32'),
	                       'max_clock_rate' : np.array([745,745],dtype='int32'), #in Mhz
			       'l1_cache_used': np.array([0,1])})

print(deviceQueryDF);

#create a dataframe with zero rows, just the colums labels
eventsDF = pd.read_csv("../data/eventsNames-3X.csv");

metricsDF = pd.read_csv("../data/metricsNames-3X.csv");

tracesDF = pd.read_csv("../data/tracesNames-3X.csv");

#to access columns:
#df.columns
#df.columns[0] ...

#to list column types: df.dtypes



