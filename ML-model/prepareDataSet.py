import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import logging

from pandas import DataFrame

logging.basicConfig(filename='logfile.log',level=logging.WARNING)

#TODO: Must validata data first!
#TODO: Check OVERFLOWS
#TODO: Add more compute versions
#TODO: Append gpu data
#TODO: parametrize for events and traces

#Compute Version
computeVersion = 3

# to control which GPU data to use
gpus = pd.Series(["Tesla-K40","Tesla-k40-UsingL1","GTX-680","Titan"]);

#Explicitly exclude apps that won't work for us 
appExcludeList = pd.Series(["bitonic","trans"]);

# Metrics features to extract
metricsFeatures = pd.Series(['L1 Global Hit Rate','L2 Hit Rate (L1 Reads)','Shared Load Transactions','Shared Store Transactions','Global Load Transactions','Global Store Transactions']);

#Events features to extract
eventsFeatures = pd.Series(['threads_launched']);

#Traces features to extract
tracesFeatures = pd.Series(['Duration']);

deviceQueryDF = pd.DataFrame({ 'gpu_name' : gpus,
			       'compute_version': np.array([computeVersion,computeVersion,computeVersion,computeVersion]),
			       'num_of_cores': np.array([2880,2880,1536,2688],dtype='int32'),
	                       'max_clock_rate' : np.array([745,745,1058,876],dtype='int32'), #in Mhz
			       'l1_cache_used': np.array([0,1,1,1])}) # check again

deviceQueryDF.to_csv('deviceData.csv');

#create a dataframe with zero rows, just the colums labels
eventsHeaderDF = pd.read_csv("../data/eventsNames-3X.csv");

metricsHeaderDF = pd.read_csv("../data/metricsNames-3X.csv");
metricsHeaderDF = metricsHeaderDF [metricsFeatures] ;
print metricsHeaderDF
tracesHeaderDF = pd.read_csv("../data/tracesNames-3X.csv");

#Contians folder paths for GPUs
gpuPath=pd.Series([""]);

processFile=True ;
counter=0;
## Get traces data:
#Construct folder paths and search for traces in each GPU directory
for i in range(0,gpus.size):
	gpuPath[i] = "../data/"+gpus[i]+"/run_0/";

	for file in os.listdir(gpuPath[i]):
	
		for j in range(0,appExcludeList.size):

			if (file.startswith(appExcludeList[j])):
				processFile=False;

		if (processFile == True) and file.endswith("-kernel-traces.csv"): 
		
			#get app name
		        appNameEnd = file.find('-kernel-traces.csv');
			appName = file[0:appNameEnd];
			#print appName;
			fullTracesName = gpuPath[i] + file;
			fullEventsName = gpuPath[i] + appName + "-events.csv";
			fullMetricsName = gpuPath[i] + appName + "-metrics.csv";
		
			#Check that events and metrics files exist for that app
			if (os.path.isfile(fullEventsName) and os.path.isfile(fullMetricsName)):
	
				#Read traces,events and metrics of that app in dataframe
				tempDF = pd.read_csv(fullTracesName,header=None, names = tracesHeaderDF.columns );
				tempEventsDF = pd.read_csv(fullEventsName,header=None, names = eventsHeaderDF.columns );
				#tempMetricsDF = pd.read_csv(fullMetricsName,header=None, names = metricsHeaderDF.columns );
				tempMetricsDF = pd.read_csv(fullMetricsName,header=None, names =metricsFeatures);

				#Check that events, metrics and traces files have the same sample size
				if(len(tempDF.index) == len(tempEventsDF.index) == len(tempMetricsDF.index) ):

					logging.info( "Processing traces, metrics and events for: "+gpus[i]+"\\" + appName + " ...");
					counter=counter+1;

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
tracesHeaderDF = tracesHeaderDF.reset_index();
tracesHeaderDF = tracesHeaderDF.drop('index', 1)
#write to csv file
tracesHeaderDF.to_csv("traces.csv");

#reset the index
eventsHeaderDF = eventsHeaderDF.reset_index();
eventsHeaderDF = eventsHeaderDF.drop('index', 1)
#write to csv file
eventsHeaderDF.to_csv("events.csv");
#Take subset of events
eventsHeaderDF = eventsHeaderDF[eventsFeatures];

#reset the index
metricsHeaderDF = metricsHeaderDF.reset_index();
metricsHeaderDF = metricsHeaderDF.drop('index', 1)
#Write to csv file			
metricsHeaderDF.to_csv("metrics.csv");
#Take subset of metrics( may change in other compute capabilities)
#metricsHeaderDF = metricsHeaderDF[metricsFeatures];

#Create dataset
datasetDF= eventsHeaderDF.join(metricsHeaderDF);
datasetDF = datasetDF.join(tracesHeaderDF);
datasetDF.to_csv("datasetDF.csv");

print "Terminated: " + str(counter) + " apps processed, "+ str(len(datasetDF.index)) + " samples collected";

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


