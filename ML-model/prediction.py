import numpy as np
from sklearn import datasets
from sklearn import linear_model
from sklearn import preprocessing

#TODO: feature normalization
#TODO: negative predicted values ?

#Import all dataset
dataset = np.genfromtxt('datasetDF.csv', dtype=float, delimiter=',', skip_header =1);
print dataset.shape;

#Calculate: number of samples,features, output index, training set size ..
samplesCount = dataset.shape[0];
columnsCount = dataset.shape[1];
featuresCount = dataset.shape[1]-1;
outputIndex = dataset.shape[1]-1;

trainingSetCount = int(80 * samplesCount /100);

#For training set: separate the feature set from the target attributes
X = dataset[0:trainingSetCount,0:featuresCount]; # last one not included
y = dataset[0:trainingSetCount,outputIndex];

#Scale values with mean = zero and standard deviation =1
std_scale = preprocessing.StandardScaler().fit(X)
X_std = std_scale.transform(X)
print X_std;


#Training phase
lr = linear_model.LinearRegression();
lr.fit(X_std,y);

#Scale test set
X_val = dataset[trainingSetCount+1:samplesCount,0:featuresCount];
X_val_std = std_scale.transform(X_val)
print X_val_std;

#Prediction for test set
print lr.predict(X_val_std)


