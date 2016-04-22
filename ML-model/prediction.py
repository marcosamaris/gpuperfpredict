import numpy as np
from sklearn import datasets
from sklearn import linear_model
from sklearn import preprocessing
from sklearn.metrics import mean_absolute_error
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
from sklearn import svm
import logging

#TODO: check negatively predicted values
#TODO: use different linear models
#TODO: for comparison between different ML models use mean square error, for comparison with analytical model use accuracy: mean(predicted/true value * 100)

logging.basicConfig(filename='prediction_results.log',filemode='w',level=logging.WARNING)

#add matmul gpu uncoalased ..
#========================Preparing the data===================================#

#Import all dataset
dataset = np.genfromtxt('dataset_matMul.csv', dtype=float, delimiter=',', skip_header =1);
print dataset.shape;

#Calculate: number of samples,features, output index, training set size ..
featureStart = 1;
samplesCount = dataset.shape[0];
columnsCount = dataset.shape[1];
featuresCount = dataset.shape[1]-1;
outputIndex = dataset.shape[1]-1;

trainingSetCount = int(80 * samplesCount /100);
#If I needed to overwrite it
trainingSetCount = 530;

print trainingSetCount
#For training set: separate the feature set from the target attributes
X = dataset[featureStart:trainingSetCount,featureStart:featuresCount]; # last one not included
y = dataset[featureStart:trainingSetCount,outputIndex];

#True Output values that will be used in calcuating the accuracy of prediction
y_true = dataset[trainingSetCount+1:samplesCount,outputIndex]
print y_true

#Scale values with mean = zero and standard deviation =1
std_scale = preprocessing.StandardScaler().fit(X)
X_std = std_scale.transform(X)
#print X_std;

#Scale test set
X_val = dataset[trainingSetCount+1:samplesCount,featureStart:featuresCount];
X_val_std = std_scale.transform(X_val)
#print X_val_std;

#=====================Ordinary Least Squares Linear model======================================
print "=====================Ordinary Least Squares================"
#Training phase
lr = linear_model.LinearRegression();
lr.fit(X_std,y);

training_error = lr.score(X_std,y);
print "Training error = " + str(training_error) + ", best is 1.0";

test_error = lr.score(X_val_std,y_true );
print "Test error = " + str(test_error) + ", best is 1.0";

#Prediction for test set
y_pred = lr.predict(X_val_std)
#print y_pred

#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";

#accuracy = np.mean( np.divide(y_pred,y_true) )
#print accuracy
#===================Ridge Regression==========================================
print "=======================Ridge Regression=================="
#Try different regularization parameters
ridgeCV = linear_model.RidgeCV(alphas=[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0])

ridgeCV.fit(X_std,y);
print "Used alpha: " + str(ridgeCV.alpha_);

training_error = ridgeCV.score(X_std,y);
print "Training error = " + str(training_error) + ", best is 1.0";

test_error = ridgeCV.score(X_val_std,y_true );
print "Test error = " + str(test_error) + ", best is 1.0";

y_pred = ridgeCV.predict(X_val_std);

#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";

#accuracy = np.mean( np.divide(y_pred,y_true) )
#print accuracy


#=========================LASSO ==============================

print "=======================LASSO Regression=================="
#Try different regularization parameters
lassoCV = linear_model.LassoCV(alphas=[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0])

lassoCV.fit(X_std,y);
print "Used alpha: " + str(lassoCV.alpha_);

training_error = lassoCV.score(X_std,y);
print "Training error = " + str(training_error) + ", best is 1.0";

test_error = lassoCV.score(X_val_std,y_true );
print "Test error = " + str(test_error) + ", best is 1.0";

y_pred = lassoCV.predict(X_val_std);

#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";

#=========================Elastic Net ====================================
print "================Elastic Net ===================="	

enet = linear_model.ElasticNetCV(l1_ratio = [.1, .5, .7, .9, .95, .99, 1] ,alphas=[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0] );

enet.fit(X_std,y);
print "Used alpha: " + str(enet.alpha_);
print "Used l1_ratio: " + str(enet.l1_ratio_);

training_error = enet.score(X_std,y);
print "Training error = " + str(training_error) + ", best is 1.0";

test_error = enet.score(X_val_std,y_true );
print "Test error = " + str(test_error) + ", best is 1.0";

y_pred = enet.predict(X_val_std);

#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";


#=======================Support Vector Regression=============================
print "================Support Vector Regression===================="
svmR = svm.SVR();

svmR.fit(X_std,y);

training_error = svmR.score(X_std,y);
print "Training error = " + str(training_error) + ", best is 1.0";

test_error = svmR.score(X_val_std,y_true );
print "Test error = " + str(test_error) + ", best is 1.0";

y_pred = svmR.predict(X_val_std);
#print y_pred
#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";

#accuracy = np.mean( np.divide(y_pred,y_true) )
#print accuracy

