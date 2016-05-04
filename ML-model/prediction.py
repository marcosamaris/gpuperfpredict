import pandas as pd
import numpy as np
from sklearn import preprocessing, linear_model, svm, grid_search
from sklearn.ensemble.forest import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score, make_scorer
import logging
from pandas import DataFrame

#TODO: check negatively predicted values

#Gradient tree boosting 
#http://scikit-learn.org/stable/modules/classes.html#module-sklearn.ensemble

experiment_type = "compute"
#options: "compute","classical"

#Output folder name
outputFolder = ""
datasetFolder = ""

#Output folder name is set according to experiment type
if experiment_type == "compute": 
	datasetFolder = "datasets/with_compute_features/"
	outputFolder = "prediction_results/with_compute_features/"
elif experiment_type == "classical":
	datasetFolder = "datasets/classical/"
	outputFolder = "prediction_results/classical/"

logging.basicConfig(filename=outputFolder+'prediction_results.log',filemode='w',level=logging.INFO)

#========================Preparing the data===================================#

#Import all dataset
roundNumber = 5;
architecuteList = pd.Series(["Maxwell","Kepler"]);
appIncludeList = pd.Series(["matrix_sum","matMul","dotProd","subSeqMax","vectorAdd"]);

for i in range(0,appIncludeList.size):
	
	dataset = np.genfromtxt(datasetFolder+'dataset_'+appIncludeList[i]+'.csv', dtype=float, delimiter=',', skip_header =1);
	print dataset.shape;

	#Calculate: number of samples,features, output index, training set size ..
	featureStart = 1;
	columnsCount = dataset.shape[1];
	featuresCount = dataset.shape[1]-1;
	outputIndex = dataset.shape[1]-1;
	
	for j in range(0,architecuteList.size):	
		
		shape = pd.read_csv("result_shape.csv");
		shape=shape.set_index('Type');

		trainingGPUs=""; 
		testGPUs=""

		#for generic experiment: decide which GPUs are going to be used for training, and which for testing, according to architecture	
		if (architecuteList[j]== "Kepler"):
			trainingGPUs = dataset[:,0] < 4;
			testGPUs = dataset[:,0] == 4;

		elif(architecuteList[j]== "Maxwell"):
			trainingGPUs = np.logical_and(dataset[:,0] > 4, dataset[:,0] < 9);
			testGPUs = dataset[:,0] == 9;
			

		#Training set features (inputs)
		X = dataset[trainingGPUs,featureStart:featuresCount];
		print X
		
		#Training set outputs
		y = dataset[trainingGPUs,outputIndex];
		print y

		#True output values for test set
		y_true = dataset[testGPUs,outputIndex]
		print y_true	

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

		def calculateAccuracy(y_true,y_pred):
			return np.mean( np.divide(y_pred,y_true) );

		def printErrors(lr,modelType):
			training_error = lr.score(X_std,y);
			training_error = round(training_error,roundNumber)
			print "Training error = " + str(training_error) + ", best is 1.0";
			shape['Training error'][modelType] = training_error

			test_error = lr.score(X_val_std,y_true );
			test_error = round(test_error,roundNumber)
			print "Test error = " + str(test_error) + ", best is 1.0";
			shape['Test error'][modelType] = test_error

			#Calculating prediction error
			error = mean_absolute_error(y_true,y_pred);
			error = round(error,roundNumber)
			print "Mean absolute error: " + str(error) + ", best is zero";
			shape['Mean absolute error'][modelType] = error;

			error = mean_squared_error(y_true, y_pred) 
			error = round(error,roundNumber)
			print "Mean squared error: " + str(error) + ", best is zero";
			shape['Mean squared error'][modelType] = error;

			accuracy =calculateAccuracy(y_true,y_pred);
			print accuracy
			shape['Accuracy'][modelType] = accuracy 

			parameterString = "";
			if (modelType == "random_forest_regressor" or modelType == "support_vector_regression" ):
				parameterString = lr.best_params_
			elif (modelType == "elastic_net"):
				parameterString = "Alpha: " + str(lr.alpha_) + ", l1_ratio: " + str(lr.l1_ratio_);
			elif (modelType == "ordinary" ):
				parameterString = "N/A";
			elif (modelType == "lasso" or modelType == "ridge"):
				parameterString = "Alpha: " + str(lr.alpha_);
				
			shape['Parameters'][modelType] = parameterString;
		   	
			return

		print "======================Application: "+appIncludeList[i];
		#=====================Ordinary Least Squares Linear model======================================
		print "=====================Ordinary Least Squares================"
		#Training phase
		lr = linear_model.LinearRegression();
		lr.fit(X_std,y);

		#Prediction for test set
		y_pred = lr.predict(X_val_std)

		printErrors(lr,"ordinary");

		#===================Ridge Regression==========================================
		print "=======================Ridge Regression=================="
		#Try different regularization parameters
		ridgeCV = linear_model.RidgeCV(alphas=[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0])

		ridgeCV.fit(X_std,y);
		print "Used alpha: " + str(ridgeCV.alpha_);

		y_pred = ridgeCV.predict(X_val_std);

		printErrors(ridgeCV,"ridge");

		#=========================LASSO ==============================

		print "=======================LASSO Regression=================="
		#Try different regularization parameters
		lassoCV = linear_model.LassoCV(alphas=[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0])

		lassoCV.fit(X_std,y);
		print "Used alpha: " + str(lassoCV.alpha_);

		y_pred = lassoCV.predict(X_val_std);

		printErrors(lassoCV,"lasso");
		#=========================Elastic Net ====================================
		print "================Elastic Net ===================="	
		enet = linear_model.ElasticNetCV(l1_ratio = [.1, .5, .7, .9, .95, .99, 1] ,alphas=[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0] );

		enet.fit(X_std,y);

		y_pred = enet.predict(X_val_std);

		printErrors(enet,"elastic_net");
		#=======================Support Vector Regression=============================
		print "================Support Vector Regression===================="
		
		parameters = [ { 'kernel':['poly'],'C':[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0], 'degree' :[1,2,3]  },
			       {  'kernel':['linear'],'C':[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0] }, 
			       {  'kernel':['rbf'],'C':[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0]} ]
						
		svr = svm.SVR();

		clf = grid_search.GridSearchCV(svr, parameters)		

		clf.fit(X_std,y);

		y_pred = clf.predict(X_val_std);
		
		printErrors(clf,"support_vector_regression");

		#====================Random Forest Regressor==========================
		print "=========Random Forest Regressor==========="

		parameters = { 'n_estimators':[2, 4, 8, 16, 32, 64, 128, 256, 512, 1024], 'max_features':( 'auto','sqrt','log2' ) }
		randomForest = RandomForestRegressor();
	
		#Pass a custom accuracy scorer to GridSearchCV, how to tell that 1 is the best ?!
		#accuracyScorer = make_scorer (calculateAccuracy );
 		#scoring=accuracyScorer
		
		clf = grid_search.GridSearchCV(randomForest, parameters);
		clf.fit(X_std,y);

		y_pred = clf.predict(X_val_std);
		
		printErrors(clf,"random_forest_regressor");

		shape.to_csv(outputFolder+"results_"+appIncludeList[i]+"_"+architecuteList[j]+".csv");

