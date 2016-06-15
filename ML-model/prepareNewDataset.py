import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import logging

#TODO: Combine all apps together of the same architecture, then to do the learning
#
from pandas import DataFrame

inputFolder="../R-code/Datasets/Apps/"
outputFolder="datasets/with_compute_features_new_test/"

#Explicitly include apps that we need to collect data from 
appIncludeList = pd.Series(["matMul_gpu", "matMul_gpu_sharedmem", "matMul_gpu_uncoalesced", "matMul_gpu_sharedmem_uncoalesced", 
			   "dotProd","matrix_sum_coalesced","matrix_sum_normal", "subSeqMax", "vectorAdd"]);

#For Kepler Architecture
#Cache data shoud be removed because it's zeroes anyways since L1 cache is disabled in the used GPUs
features3X =pd.Series(['gpu_id', 'l1_cache_used', 'max_clock_rate', 'num_of_cores','threads_launched', 'L1.Global.Hit.Rate', 'L2.Hit.Rate..L1.Reads.', 			     'Shared.Load.Transactions', 'Shared.Store.Transactions',  'Global.Load.Transactions', 'Global.Store.Transactions', 'Instructions.Executed', 'Instructions.Issued', 'Executed.IPC', 'Achieved.Occupancy', 'l1_global_load_hit', 'l1_global_load_miss','Duration']);

features5X = pd.Series(['gpu_id', 'l1_cache_used', 'max_clock_rate', 'num_of_cores', 'Instructions.Executed', 'Instructions.Issued', 'Executed.IPC', 'Achieved.Occupancy', 'Global.Hit.Rate','Shared.Load.Transactions','Shared.Store.Transactions','Global.Load.Transactions','Global.Store.Transactions','Duration']);

architecuteList = pd.Series(["Maxwell","Kepler"]);

dataFrame3X=pd.DataFrame();
dataFrame5X=pd.DataFrame();

calculatedDataDF = pd.DataFrame( columns = pd.Series(['threads_launched']) );

for j in range(0,appIncludeList.size):

	#for compute 3
	temp1 =  pd.read_csv(inputFolder+appIncludeList[j]+"-GPU30.csv")
	temp2 =  pd.read_csv(inputFolder+appIncludeList[j]+"-GPU35.csv")

	#for compute 5
	temp3 =  pd.read_csv(inputFolder+appIncludeList[j]+"-GPU50.csv")
	temp4 =  pd.read_csv(inputFolder+appIncludeList[j]+"-GPU52.csv")


	#Rearrange: GPU ID as the first column, and Duration as the last column
	temp1= temp1 [['gpu_id', 'num_of_cores', 'max_clock_rate', 'l1_cache_used', 'threads_launched', 
                                   'Achieved.Occupancy', 'Executed.IPC', 'Global.Load.Transactions', 'Global.Store.Transactions', 'Instructions.Executed',            'Instructions.Issued', 'L2.Hit.Rate..L1.Reads.', 'Shared.Load.Transactions', 'Shared.Store.Transactions', 'Duration']]

	temp2= temp2 [['gpu_id', 'num_of_cores', 'max_clock_rate', 'l1_cache_used', 'threads_launched', 
                                   'Achieved.Occupancy', 'Executed.IPC', 'Global.Load.Transactions', 'Global.Store.Transactions', 'Instructions.Executed',            'Instructions.Issued', 'L2.Hit.Rate..L1.Reads.', 'Shared.Load.Transactions', 'Shared.Store.Transactions', 'Duration']]

	#to remove any non numeric value
	temp1 = temp1.convert_objects(convert_numeric=True).dropna();
	temp2 = temp2.convert_objects(convert_numeric=True).dropna();
	temp3 = temp3.convert_objects(convert_numeric=True).dropna();
	temp4 = temp4.convert_objects(convert_numeric=True).dropna();

	temp1.to_csv(outputFolder+"dataset_Kepler_"+appIncludeList[j]+"1.csv",index=False);
	temp2.to_csv(outputFolder+"dataset_Kepler_"+appIncludeList[j]+"2.csv",index=False);
	temp3.to_csv(outputFolder+"dataset_Maxwell_"+appIncludeList[j]+"1.csv",index=False);
	temp4.to_csv(outputFolder+"dataset_Maxwell_"+appIncludeList[j]+"2.csv",index=False);

	temp5 = pd.read_csv(outputFolder+"dataset_Kepler_"+appIncludeList[j]+"1.csv")
	temp6 = pd.read_csv(outputFolder+"dataset_Kepler_"+appIncludeList[j]+"2.csv")
	temp7 = pd.read_csv(outputFolder+"dataset_Maxwell_"+appIncludeList[j]+"1.csv")
	temp8 = pd.read_csv(outputFolder+"dataset_Maxwell_"+appIncludeList[j]+"2.csv")

	temp5 = temp5.append(temp6)
	temp5 = temp5.sort(['gpu_id'])	
	
	temp7 = temp7.append(temp8)
	temp7 = temp7.reset_index().drop('index', 1);

	temp7['threads_launched'] = pd.Series(np.random.randn(len(temp7.index)), index=temp7.index)
	temp7['threads_launched'] = temp7['Grid.X'] * temp7['Grid.Y'] *  temp7['Grid.Z'] * temp7['Block.X'] * temp7['Block.Y'] *  temp7['Block.Z'];

	temp7 = temp7.sort(['gpu_id'])	

	temp7=temp7[['gpu_id', 'l1_cache_used', 'max_clock_rate', 'num_of_cores','threads_launched', 'Instructions.Executed', 'Instructions.Issued', 'Executed.IPC', 'Achieved.Occupancy', 'Global.Hit.Rate','Shared.Load.Transactions','Shared.Store.Transactions','Global.Load.Transactions','Global.Store.Transactions','Duration']]

	temp5.to_csv(outputFolder+"dataset_Kepler_"+appIncludeList[j]+".csv",index=False);
	temp7.to_csv(outputFolder+"dataset_Maxwell_"+appIncludeList[j]+".csv",index=False);







		

