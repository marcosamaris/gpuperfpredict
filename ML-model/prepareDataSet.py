import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from pandas import DataFrame

#PLAN: get data of 1 GPU first with and without L1 cache

# to control which GPU data to use

gpus = pd.Series(["Tesla-K40","Tesla-k40-UsingL1"]);

#Contians folder paths for GPUs
gpuPath=pd.Series([""]);

#Construct folder paths
for i in range(0,gpus.size):
	gpuPath[i] = "../data/"+gpus[i];

print(gpuPath);

with open(fname) as f:
    content = f.readlines()

#create a dataframe with zero rows, just the colums labels
eventsDF = pd.read_csv("../data/eventsNames-3X.csv");

metricsDF = pd.read_csv("../data/metricsNames-3X.csv");

tracesDF = pd.read_csv("../data/tracesNames-3X.csv");

#to access columns:
#df.columns
#df.columns[0] ...

#to list column types: df.dtypes



