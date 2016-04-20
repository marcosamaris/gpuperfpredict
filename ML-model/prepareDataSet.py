import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import logging

from pandas import DataFrame

logging.basicConfig(filename='logfile.log',filemode='w',level=logging.WARNING)

#TODO: Must validata data first!
#TODO: Add more compute versions
#TODO: format float fraction
#TODO: you can use dataset for each application
#TODO: Possibility for features: input size, "bandwidth" and "L2 cache size" from device info

#In metrics: L1 Global Hit Rate','L2 Hit Rate (L1 Reads) don't exist in compute 5 !!

#Instead there is: Global Hit rate instead of "L2 Hit Rate (L1 Reads)"
#L1 Global Hit Rate = zeros

#In events: l1_global_load_hit', 'l1_global_load_miss don't exist in compute 5
# put = zero

#File Paths:
deviceInfo = "deviceInfo.csv";

#Explicitly include apps that we need to collect data from 
appIncludeList = pd.Series(["matMul"]);

#Explicitly exclude apps that won't work for us, not used currently 
appExcludeList = pd.Series(["bitonic","trans"]);

#Get device data from CSV file, easier than hardcoding it
deviceQueryDF = pd.read_csv(deviceInfo);
gpus = deviceQueryDF['gpu_name'];

#Device features
deviceFeatures = pd.Series(['gpu_id','num_of_cores','max_clock_rate','l1_cache_used']);

#create a dataframe with zero rows, just the colums labels
eventsHeaderDF = pd.read_csv("../data/eventsNames-3X.csv" );

metricsHeaderDF = pd.read_csv("../data/metricsNames-3X.csv");

tracesHeaderDF = pd.read_csv("../data/tracesNames-3X.csv");

#To be used to add corresponding device info for each sample
deviceDataDF = pd.DataFrame(columns = deviceFeatures);

calculatedDataDF = pd.DataFrame( columns = pd.Series(['threads_number']) );

# Metrics features to extract
metricsFeatures = pd.Series(['L1 Global Hit Rate','L2 Hit Rate (L1 Reads)','Shared Load Transactions','Shared Store Transactions','Global Load Transactions','Global Store Transactions']);

#Events features to extract
eventsFeatures = pd.Series(['l1_global_load_hit', 'l1_global_load_miss']); #what about store ?

#Traces features to extract
tracesFeatures = pd.Series(['Duration']);

#Contians folder paths for GPUs
gpuPath=pd.Series([""]);
processFile=True ;
counter=0;

## Get traces data:
#Construct folder paths and search for traces in each GPU directory
for i in range(0,gpus.size):
	gpuPath[i] = "../data/"+gpus[i]+"/run_0/";

	for file in os.listdir(gpuPath[i]):
	
		for j in range(0,appIncludeList.size):

			if (not file.startswith(appIncludeList[j])):
				processFile=False;

		if (processFile == True) and file.endswith("-kernel-traces.csv"): 
		
			#get app name
		        appNameEnd = file.find('-kernel-traces.csv');
			appName = file[0:appNameEnd];
			fullTracesName = gpuPath[i] + file;
			fullEventsName = gpuPath[i] + appName + "-events.csv";
			fullMetricsName = gpuPath[i] + appName + "-metrics.csv";
		
			#Check that events and metrics files exist for that app
			if (os.path.isfile(fullEventsName) and os.path.isfile(fullMetricsName)):
	
				#Read traces,events and metrics of that app in dataframe
				tempDF = pd.read_csv(fullTracesName,header=None, names = tracesHeaderDF.columns );
				tempEventsDF = pd.read_csv(fullEventsName,header=None, names = eventsHeaderDF.columns);
				tempMetricsDF = pd.read_csv(fullMetricsName,header=None, names =metricsHeaderDF.columns);

				#Check that events, metrics and traces files have the same sample size
				if(len(tempDF.index) == len(tempEventsDF.index) == len(tempMetricsDF.index) ):

					print "Processing traces, metrics and events for: "+gpus[i]+"\\" + appName + " ...";
					logging.warning( "Processing traces, metrics and events for: "+gpus[i]+"\\" + appName + " ..." );

					counter=counter+1;

					#Device info to be appended to each sample					
					deviceQuerytoAppend = deviceQueryDF[(deviceQueryDF['gpu_name']==gpus[i])][deviceFeatures];
					
					#Handle cases related to individual samples
					for k in range (0,len(tempDF.index)):

						#Add GPU info for each sample
						deviceDataDF = deviceDataDF.append(deviceQuerytoAppend);
						
						#Calculate number of threads using traces data
						threads_number = tempDF['Grid X'][k] * tempDF['Grid Y'][k] *  tempDF['Grid Z'][k] * tempDF['Block X'][k] * tempDF['Block Y'][k] *  tempDF['Block Z'][k];
						#Add to each entry the number of threads calculated as above
						calculatedDataDF.loc[len(calculatedDataDF)] = threads_number;

					#Add traces of that app
					tracesHeaderDF = tracesHeaderDF.append(tempDF);

					#Add events of that app
					eventsHeaderDF = eventsHeaderDF.append(tempEventsDF);

					#Add metrics of that app
					metricsHeaderDF = metricsHeaderDF.append(tempMetricsDF);
		

				# Else: log that they don't have the same size!
				else:
					logging.warning(" "+ gpus[i]+"\\" + appName + ": Metrics, traces and events data are not equal in size.");
						
			# Else: Log that metrics or events are missing			
			else:
				if not os.path.isfile(fullEventsName):
					logging.warning(" "+ gpus[i]+"\\" + appName + ": Events data is missing.");
				if not os.path.isfile(fullMetricsName):
					logging.warning(" "+ gpus[i]+"\\" + appName +": Metrics data is missing.") ;

		processFile=True;

#Select only duration
tracesHeaderDF = tracesHeaderDF[tracesFeatures];

#reset the index
tracesHeaderDF = tracesHeaderDF.reset_index().drop('index', 1);
#write to csv file
tracesHeaderDF.to_csv("traces.csv");

#reset the index
eventsHeaderDF = eventsHeaderDF.reset_index().drop('index', 1);
#Select only wanted events
eventsHeaderDF = eventsHeaderDF[eventsFeatures];
#write to csv file
eventsHeaderDF.to_csv("events.csv");


#reset the index
metricsHeaderDF = metricsHeaderDF.reset_index().drop('index', 1);
#Select metrics features 
metricsHeaderDF = metricsHeaderDF[metricsFeatures];
#Write to csv file			
metricsHeaderDF.to_csv("metrics.csv");

deviceDataDF = deviceDataDF.reset_index().drop('index', 1);
#Write to csv file
#deviceDataDF.to_csv("device.csv");

calculatedDataDF = calculatedDataDF.reset_index().drop('index', 1);

#Create dataset
datasetDF = deviceDataDF.join(calculatedDataDF);
datasetDF= datasetDF.join(eventsHeaderDF);
datasetDF= datasetDF.join(metricsHeaderDF);
datasetDF = datasetDF.join(tracesHeaderDF);

#If L1 cache is not used, then set l1_global_load_hit and l1_global_load_miss to zero
datasetDF.ix[datasetDF['l1_cache_used']==0, 'l1_global_load_hit'] = 0;
datasetDF.ix[datasetDF['l1_cache_used']==0, 'l1_global_load_miss'] = 0;

datasetDF.to_csv("dataset"+appIncludeList[0]+"Before.csv",index=False);

#to remove any non numeric value
datasetDF = datasetDF.convert_objects(convert_numeric=True).dropna();
datasetDF.to_csv("dataset_"+appIncludeList[0]+".csv",index=False);

print "Terminated: " + str(counter) + " apps processed, "+ str(len(datasetDF.index)) + " samples collected";
logging.warning("Terminated: " + str(counter) + " apps processed, "+ str(len(datasetDF.index)) + " samples collected" );


#L1 Global Hit Rate
#DONE  t: number of threads for a kernel
#DONE  R: clock rate, extracted from GPU specs.
#DONE  P: number of cores, extracted from GPU specs.
#DONE  L1cacheused: L1 cache is used or not.
#DONE ld0 and st0: loads and stores in shared memory.
#DONE ld1 and st1: loads and stores in global memory.
#DONE L1 and L2: cache hits for L1 and L2 cache

#To include later as features:
#=================================
#Executed IPC
#Achieved Occupancy
#Global load transactions per request
#Global store transactions per request
#same for shared mem
#in events: gld_inst_8bit	gld_inst_16bit	gld_inst_32bit	gld_inst_64bit	gld_inst_128bit


