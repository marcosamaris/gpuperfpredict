import numpy as np
from sklearn import datasets
from sklearn import linear_model

# To skip the header if need be
#f = open("filename.txt")
#f.readline()  # skip the header

dataset = np.loadtxt('dummy.csv', delimiter=',')
#print dataset
print dataset.shape

# separate the data from the target attributes
X = dataset[0:10,0:114]
y = dataset[0:10,115]

print y

lr = linear_model.LinearRegression()

lr.fit(X,y)

X_val = dataset[11,0:114]
print X_val.shape
print X_val
print lr.predict(X_val.reshape(1, -1))
