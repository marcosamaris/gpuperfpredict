import pandas as pd
import numpy as np
from sklearn import preprocessing, linear_model, svm, grid_search
from sklearn.ensemble.forest import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score, make_scorer
import logging
from pandas import DataFrame
from scipy import stats

#TODO: check negatively predicted values

#Gradient tree boosting 
#http://scikit-learn.org/stable/modules/classes.html#module-sklearn.ensemble

onlyUseRandomForest = True

experiment_type = "compute_new"
#options: "compute","classical","compute_new"

#Output folder name
outputFolder = ""
datasetFolder = ""

#Output folder name is set according to experiment type
if experiment_type == "compute_new": 
	datasetFolder = "datasets/with_compute_features_new/"
	outputFolder = "prediction_results/with_compute_features_new/"
elif experiment_type == "compute": 
	datasetFolder = "datasets/with_compute_features/"
	outputFolder = "prediction_results/with_compute_features/"
elif experiment_type == "classical":
	datasetFolder = "datasets/classical/"
	outputFolder = "prediction_results/classical/"

if onlyUseRandomForest:
	outputFolder = "prediction_results/RandomForestShuffle/"

logging.basicConfig(filename=outputFolder+'prediction_results.log',filemode='w',level=logging.INFO)

shape = pd.read_csv("result_shape.csv");
shape=shape.set_index('Type');

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

#========================Preparing the data===================================#

#Import all dataset
roundNumber = 5;
architecuteList = pd.Series(["Kepler","Maxwell"]);
appIncludeList = pd.Series(["matMul","matrix_sum","dotProd","subSeqMax","vectorAdd"]);

#appIncludeList = pd.Series(["matMul_gpu", "matMul_gpu_sharedmem", "matMul_gpu_uncoalesced", "matMul_gpu_sharedmem_uncoalesced", 
#			   "dotProd","matrix_sum_coalesced","matrix_sum_normal", "subSeqMax", "vectorAdd"]);

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
			
		#Kepler Architecture Group
		gpu1= dataset[:,0] == 1;
		gpu2= dataset[:,0] == 2;
		gpu3= dataset[:,0] == 3;
		gpu4= dataset[:,0] == 4;
		gpu5= dataset[:,0] == 5;
		gpu6= dataset[:,0] == 6;

		#Maxwell Architecture Group
		gpu7= dataset[:,0] == 7;
		gpu8= dataset[:,0] == 8;
		gpu9= dataset[:,0] == 9;
		gpu10= dataset[:,0] == 10;
		
		rangeForLoop =0;
		if (architecuteList[j]== "Kepler"):
			rangeForLoop = range (1,7)
	
		elif(architecuteList[j]== "Maxwell"):
			rangeForLoop = range (7,11)

		for m in rangeForLoop:
		
			if m==1:
				trainingGPUs = np.logical_or.reduce( (gpu2,gpu3,gpu4,gpu5,gpu6));
				testGPUs = gpu1;

			elif m==2:
				trainingGPUs = np.logical_or.reduce( (gpu1,gpu3,gpu4,gpu5,gpu6));
				testGPUs = gpu2;

			elif m==3:
				trainingGPUs = np.logical_or.reduce(  (gpu1,gpu2,gpu4,gpu5,gpu6));
				testGPUs = gpu3;

			elif m==4:
				trainingGPUs = np.logical_or.reduce(  (gpu1,gpu2,gpu3,gpu5,gpu6));
				testGPUs = gpu4;

			elif m==5:
				trainingGPUs = np.logical_or.reduce((gpu1,gpu2,gpu3,gpu4,gpu6));
				testGPUs = gpu5;
		
			elif m==6:
				trainingGPUs = np.logical_or.reduce( (gpu1,gpu2,gpu3,gpu4,gpu5));
				testGPUs = gpu6;
			
			elif m==7:
				trainingGPUs = np.logical_or.reduce((gpu8,gpu9,gpu10));
				testGPUs = gpu7;

			elif m==8:
				trainingGPUs = np.logical_or.reduce((gpu7,gpu9,gpu10));
				testGPUs = gpu8;

			elif m==9:
				trainingGPUs = np.logical_or.reduce((gpu7,gpu8,gpu10));
				testGPUs = gpu9;

			elif m==10:
				trainingGPUs = np.logical_or.reduce((gpu7,gpu8,gpu9));
				testGPUs = gpu10;
	
			# For calculating accuracy and abs percentage deviation for each sample
			accuracy_sample_temp = 0
			abs_percent_dev_temp = 0
			
			# For calculating accuracy and abs percentage deviation for each sample
			accuracy_sample_temp = 0
			abs_percent_dev_temp = 0

			for k in range (0,10):
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

				logging.info("======================"+appIncludeList[i]+"  " +architecuteList[j]);
				logging.info("Training set size: "+str(X.shape[0]) );
				logging.info("Test set size: "+str(X_val.shape[0]) );

				#print "======================Application: "+appIncludeList[i];

				#print "=========Random Forest Regressor==========="

				#parameters = { 'n_estimators':[2, 4, 8, 16, 32, 64, 128, 256, 512, 1024], 'max_features':( 'auto','sqrt','log2' ) }
				#randomForest = RandomForestRegressor( n_estimators = 16 );
				clf  = RandomForestRegressor( n_estimators = 16 );
	
				#clf = grid_search.GridSearchCV(randomForest, parameters);
				clf.fit(X_std,y);

				y_pred = clf.predict(X_val_std);
				
				#==================Processing of Results==================				
				accuracy_sample =  np.divide(y_pred,y_true);
				abs_percent_dev =  np.absolute( np.divide( (y_true - y_pred),y_true )  );
				

				printErrorRandomForest(clf,k);
				randomForestResutls.to_csv(outputFolder+"results_"+appIncludeList[i]+"_"+architecuteList[j]+"_RandomForestResults_"+str(m)+".csv");

				


