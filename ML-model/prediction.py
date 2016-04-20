import numpy as np
from sklearn import datasets
from sklearn import linear_model
from sklearn import preprocessing
from sklearn.metrics import mean_absolute_error
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
from sklearn import svm

#TODO: check negatively predicted values
#TODO: use different linear models
#TODO: for comparison between different ML models use mean square error, for comparison with analytical model use accuracy: mean(predicted/true value * 100)

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

#Prediction for test set
y_pred = lr.predict(X_val_std)
#print y_pred

#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";

error = r2_score(y_true, y_pred)
print "R^2 Error: " + str(error) + ", best is 1.0";

#===================Ridge Regression==========================================
print "=======================Ridge Regression=================="
#Try different regularization parameters
ridgeCV = linear_model.RidgeCV(alphas=[0.01,0.1,0.3,0.6, 1.0,3.0,6.0, 10.0])

ridgeCV.fit(X_std,y);
print "Used alpha: " + str(ridgeCV.alpha_);

y_pred = ridgeCV.predict(X_val_std);

#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";

error = r2_score(y_true, y_pred)
print "R^2 Error: " + str(error) + ", best is 1.0";

#=======================Support Vector Regression=============================
print "================Support Vector Regression===================="
svmR = svm.SVR();

svmR.fit(X_std,y);

y_pred = svmR.predict(X_val_std);
#print y_pred
#Calculating prediction error
error = mean_absolute_error(y_true,y_pred);
print "Mean absolute error: " + str(error) + ", best is zero";

error = mean_squared_error(y_true, y_pred) 
print "Mean squared error: " + str(error) + ", best is zero";

error = r2_score(y_true, y_pred)
print "R^2 Error: " + str(error) + ", best is 1.0";



