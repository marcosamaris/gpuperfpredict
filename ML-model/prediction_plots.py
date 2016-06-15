import pandas as pd
import numpy as np
from sklearn import preprocessing, linear_model, svm, grid_search
from sklearn.ensemble.forest import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score, make_scorer
import logging
from pandas import DataFrame
from scipy import stats
import matplotlib.pyplot as plt

#Output folder name
outputFolder = "prediction_results/RandomForestShuffle/"
datasetFolder = "datasets/with_compute_features_new/"

randomForestResutls = pd.DataFrame(index=range(0,30) , columns=['Training error','Test error','Mean absolute error','Mean squared error','Accuracy','Mean Absolute Percentage Accuracy'] );

#=======================Helping FUNCTIONS=====================================
def calculateAccuracy(y_true,y_pred):
			return np.mean( np.divide(y_pred,y_true) );

def calculateMeanAbsAccuracy(y_true,y_pred):
	return np.mean(   
	       np.absolute( 
	       np.divide( (y_true - y_pred),y_true )  ) );

def printErrorRandomForest( lr,k):

	training_error = lr.score(X_std,y);
	training_error = round(training_error,roundNumber)
	randomForestResutls['Training error'][k] = training_error

	test_error = lr.score(X_val_std,y_true );
	test_error = round(test_error,roundNumber)
	randomForestResutls['Test error'][k] = test_error

	#Calculating prediction error
	error = mean_absolute_error(y_true,y_pred);
	error = round(error,roundNumber)
	randomForestResutls['Mean absolute error'][k] = error;

	error = mean_squared_error(y_true, y_pred) 
	error = round(error,roundNumber)
	randomForestResutls['Mean squared error'][k] = error;

	accuracy =calculateAccuracy(y_true,y_pred);
	randomForestResutls['Accuracy'][k] = accuracy 

	randomForestResutls['Mean Absolute Percentage Accuracy'][k] = calculateMeanAbsAccuracy(y_true,y_pred);

	return

def boxPlotKepler(all_data,arch):

	fig, axes = plt.subplots(nrows=1, ncols=5, figsize=(12, 5))
	
	axes[0].set_xlabel('matMul')
	axes[1].set_xlabel('matrix_sum')
	axes[2].set_xlabel('dotProd')
	axes[3].set_xlabel('subSeqMax')
	axes[4].set_xlabel('vectorAdd')

	# rectangular box plot
	bplot1 = axes[0].boxplot(all_data,
		                 vert=True,   # vertical box aligmnent
		                 patch_artist=True)   # fill with color

	# notch shape box plot
	bplot2 = axes[1].boxplot(all_data,
		                 notch=True,  # notch shape
		                 vert=True,   # vertical box aligmnent
		                 patch_artist=True)   # fill with color

	# fill with colors
	colors = ['pink', 'lightblue', 'lightgreen','red','yellow','black']
	for bplot in (bplot1, bplot2):
	    for patch, color in zip(bplot['boxes'], colors):
		patch.set_facecolor(color)

	# adding horizontal grid lines
	for ax in axes:
	    ax.yaxis.grid(True)
	    ax.set_xticks([y+1 for y in range(len(all_data))], )
	    ax.set_ylabel('Accuracy')

	if arch == "Kepler":
		xticklabels=['GTX-680', 'Tesla-K40', 'Tesla-K20', 'TitanBlack','Titan','Quadro']

	if arch == "Maxwell":
		xticklabels=['GTX-750', 'TitanX', 'GTX-980', 'GTX-970']

	# add x-tick labels
	plt.setp(axes, xticks=[y+1 for y in range(len(all_data))],
		 xticklabels=xticklabels)

	plt.show()


#========================Preparing the data===================================#

#Import all dataset
roundNumber = 5;
architecuteList = pd.Series(["Kepler","Maxwell"]);
architecuteList = pd.Series(["Kepler"]);
appIncludeList = pd.Series(["matMul","matrix_sum","dotProd","subSeqMax","vectorAdd"]);

for i in range(0,appIncludeList.size):
	
	for j in range(0,architecuteList.size):	

		dataset = np.genfromtxt(datasetFolder+'dataset_'+architecuteList[j]+"_"+appIncludeList[i]+'.csv', dtype=float, delimiter=',', skip_header =1);

		#Calculate: number of samples,features, output index, training set size ..
		featureStart = 1;
		columnsCount = dataset.shape[1];
		featuresCount = dataset.shape[1]-1;
		outputIndex = dataset.shape[1]-1;

		trainingGPUs=""; 
		testGPUs=""
		
		rangeForLoop =0;
		if (architecuteList[j]== "Kepler"):
			rangeForLoop = range (1,7)

			all_gpu_avg_accuracy=0;

			for m in rangeForLoop:
	
				trainingGPUs = dataset[:,0] != m;
				testGPUs = dataset[:,0] == m;
	
				#Training set features (inputs)
				X = dataset[trainingGPUs,featureStart:featuresCount];

				#Training set outputs
				y = dataset[trainingGPUs,outputIndex];

				#True output values for test set
				y_true = dataset[testGPUs,outputIndex]

				#Scale values with mean = zero and standard deviation =1
				std_scale = preprocessing.StandardScaler().fit(X)
				X_std = std_scale.transform(X)
				#print X_std;

				#Scale test set
				X_val = dataset[testGPUs,featureStart:featuresCount];
				X_val_std = std_scale.transform(X_val)
				#print X_val_std;
	
				#number of rows = number of GPUs, number of columns = number of samples
				all_gpu_avg_accuracy = np.zeros([6,len(y_true)])			

				# For calculating the average accuracy and abs percentage deviation for each sample after all runs
				accuracy_sample = np.zeros([10,len(y_true)])
				abs_percent_dev = np.zeros([10,len(y_true)])

				for k in range (0,10):

					clf  = RandomForestRegressor( n_estimators = 16 );
					clf.fit(X_std,y);

					y_pred = clf.predict(X_val_std);
				
					#==================Processing of Results==================				
					accuracy_sample_temp =  np.divide(y_pred,y_true);
					abs_percent_dev_temp =  np.absolute( np.divide( (y_true - y_pred),y_true )  );

					accuracy_sample[k,:] = accuracy_sample_temp
					abs_percent_dev[k,:] =abs_percent_dev_temp
				
					printErrorRandomForest(clf,k);
					randomForestResutls.to_csv(outputFolder+"results_"+appIncludeList[i]+"_"+architecuteList[j]+"_RandomForestResults_"+str(m)+".csv");
			
				# Average accuracy for each sample after 10 runs
				average_accuracy = np.mean (accuracy_sample, axis = 0)
				average_abs_percent_dev = np.mean (abs_percent_dev, axis = 0)
			
				#make a list
				x = [ average_accuracy, average_abs_percent_dev ]
				all_gpu_avg_accuracy[m,:average_accuracy]

			boxPlotKepler(x,"Kepler")

	
		elif(architecuteList[j]== "Maxwell"):
			rangeForLoop = range (7,11)

			all_gpu_avg_accuracy=0;

			for m in rangeForLoop:
	
				trainingGPUs = dataset[:,0] != m;
				testGPUs = dataset[:,0] == m;
	
				#Training set features (inputs)
				X = dataset[trainingGPUs,featureStart:featuresCount];

				#Training set outputs
				y = dataset[trainingGPUs,outputIndex];

				#True output values for test set
				y_true = dataset[testGPUs,outputIndex]

				#Scale values with mean = zero and standard deviation =1
				std_scale = preprocessing.StandardScaler().fit(X)
				X_std = std_scale.transform(X)
				#print X_std;

				#Scale test set
				X_val = dataset[testGPUs,featureStart:featuresCount];
				X_val_std = std_scale.transform(X_val)
				#print X_val_std;
	
				#number of rows = number of GPUs, number of columns = number of samples
				all_gpu_avg_accuracy = np.zeros([4,len(y_true)])			

				# For calculating the average accuracy and abs percentage deviation for each sample after all runs
				accuracy_sample = np.zeros([10,len(y_true)])
				abs_percent_dev = np.zeros([10,len(y_true)])

				for k in range (0,10):

					clf  = RandomForestRegressor( n_estimators = 16 );
					clf.fit(X_std,y);

					y_pred = clf.predict(X_val_std);
				
					#==================Processing of Results==================				
					accuracy_sample_temp =  np.divide(y_pred,y_true);
					abs_percent_dev_temp =  np.absolute( np.divide( (y_true - y_pred),y_true )  );

					accuracy_sample[k,:] = accuracy_sample_temp
					abs_percent_dev[k,:] =abs_percent_dev_temp
				
					printErrorRandomForest(clf,k);
					randomForestResutls.to_csv(outputFolder+"results_"+appIncludeList[i]+"_"+architecuteList[j]+"_RandomForestResults_"+str(m)+".csv");
			
				# Average accuracy for each sample after 10 runs
				average_accuracy = np.mean (accuracy_sample, axis = 0)
				average_abs_percent_dev = np.mean (abs_percent_dev, axis = 0)
			
				#make a list
				x = [ average_accuracy, average_abs_percent_dev ]
				#x = average_accuracy;
				boxPlot(x,"Maxwell")
				#plt.boxplot(x)
				#plt.show()
				#print average_accuracy
				#print average_abs_percent_dev
		
		


				


