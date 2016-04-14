import numpy as np
from sklearn import datasets
from sklearn import linear_model

# To skip the header if need be
#f = open("filename.txt")
#f.readline()  # skip the header

dataset = np.genfromtxt('datasetDF.csv', dtype=float, delimiter=',', skip_header =1);# names=True)
#print dataset
print dataset.shape;
#print dataset;

# separate the data from the target attributes
X = dataset[0:170,0:10]; # last one not included
y = dataset[0:170,10];

print X;
print y;

lr = linear_model.LinearRegression();

lr.fit(X,y);

X_val = dataset[171:178,0:10];
print X_val.shape
print X_val
print lr.predict(X_val)
