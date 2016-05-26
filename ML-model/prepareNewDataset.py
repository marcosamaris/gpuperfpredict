import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import logging

#TODO: Combine all apps together of the same architecture, then to do the learning
#
from pandas import DataFrame

#Device Info Path:
deviceInfo = "deviceInfo_L1disabled.csv";

#Get device data from CSV file, easier than hardcoding it
deviceQueryDF = pd.read_csv(deviceInfo);
gpus = deviceQueryDF['gpu_name'];

#Device features
deviceFeatures = pd.Series(['gpu_id','num_of_cores','max_clock_rate','l1_cache_used']);

#To be used to add corresponding device info for each sample
deviceDataDF = pd.DataFrame(columns = deviceFeatures);


#Explicitly include apps that we need to collect data from 
appIncludeList = pd.Series(["matMul","dotProd","matrix_sum","subSeqMax","vectorAdd"]);

#For Kepler Architecture
#for j in range(0,appIncludeList.size):

dataFrame30 = pd.read_csv("../R-code/Datasets/Apps/dotProd-GPU30.csv")
dataFrame35 = pd.read_csv("../R-code/Datasets/Apps/dotProd-GPU35.csv")

features =pd.Series(['GpuName','threads_launched','L1.Global.Hit.Rate','L2.Hit.Rate..L1.Reads.','Shared.Load.Transactions','Shared.Store.Transactions', 'Global.Load.Transactions','Global.Store.Transactions','Instructions.Executed','Instructions.Issued','Executed.IPC','Achieved.Occupancy', 'l1_global_load_hit', 'l1_global_load_miss','Duration']);

#newDataset = pd.merge(dataFrameLeft, dataFrameRight, how='inner', on=None, left_on=None, right_on=None,
#      left_index=False, right_index=False, copy=True)

dataFrame30 = dataFrame30[features]
dataFrame35 = dataFrame35[features]

dataFrame30 = dataFrame30.append (dataFrame35)
#reset the index
dataFrame30 = dataFrame30.reset_index().drop('index', 1);

#ADD gpu DATA for each sample
for k in range (0,len(dataFrame30.index)):
	deviceQuerytoAppend = deviceQueryDF[ (deviceQueryDF['gpu_name']==dataFrame30['GpuName'][k]) ][deviceFeatures];
	#Add GPU info for each sample
	deviceDataDF = deviceDataDF.append(deviceQuerytoAppend);

deviceDataDF=deviceDataDF.reset_index().drop('index', 1);
dataFrame30=dataFrame30.join(deviceDataDF);
dataFrame30.to_csv("outputTest.csv");

