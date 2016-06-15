import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import logging
import numpy as np
from sklearn.decomposition import PCA
from sklearn.feature_selection import VarianceThreshold
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression

from pandas import DataFrame

#TODO: impute missing values ? NO Just deleted it, but it decresed training set from ~6500 to ~3700, bad ?
#TODO: Try feature extraction on all dataset first, then on each application
#TODO: select best feature extraction tool
#TODO: check feature selection tools in scikit learn

##check if data is linear or not before PCA, also check ICA
##LASSO regression will give me weights for regressions, weights of features = importance

#logging.basicConfig(filename='feature_extraction.log',filemode='w',level=logging.WARNING)

clean = True

if (clean):
	data3X = pd.read_csv("../R-code/Datasets/AppGPU35.csv",low_memory=False);

	#Drop useless and repeated data
	data3X.drop({"Unnamed: 0","Device","Context","Stream","Kernel","Device.1","Context.1","Stream.1","Kernel.1","Atomic.Throughput" } , 1,inplace=True);

	#Drop these columns because there are different ranges of values in the same column, i.e ranges 0,1,2 .. then 8032200704, 10427203584 ... and also NA values
	data3X.drop( {"L1.Shared.Memory.Utilization","L2.Cache.Utilization","Texture.Cache.Utilization","Device.Memory.Utilization",
		      "System.Memory.Utilization", "Load.Store.Function.Unit.Utilization", "Arithmetic.Function.Unit.Utilization",  
		      "Control.Flow.Function.Unit.Utilization", "Texture.Function.Unit.Utilization"} , 1,inplace=True)

	#Drop input size
	data3X.drop({"Input.Size"}, 1,inplace=True)

	#Drop Duration as it's an output
	data3X.drop({"Duration"}, 1,inplace=True)

	#Drop GPU and appname
	data3X.drop({"gpu_name","AppName"}, 1,inplace=True) 

	data3X.to_csv("outputDataset3X.csv");

	#Drop labels with any NA value
	data3X = data3X.convert_objects(convert_numeric=True).dropna()
	data3X.to_csv("Data-AppGPU3X-allKernels.csv");
	
	dataset = data3X.as_matrix()

#dataset = np.genfromtxt("Data-AppGPU3X-allKernels.csv", dtype=float, delimiter=',',names = True)# skip_header =1);
#dataset = np.loadtxt("Data-AppGPU3X-allKernels.csv")
print dataset.dtype.names
print dataset.shape

#first, see variance ratio for all features, use VarianceThreshold()

variance = VarianceThreshold(10000)
output = variance.fit_transform(dataset)

print output.shape
print variance.variances_

np.savetxt("variance.csv", output, delimiter=",")
#===================================================================================================
#PCA transforms to components of highest variance, it doesn't tell you which ones are
pca = PCA();
pca.fit(dataset)

varArray = pca.explained_variance_ratio_;


#print(varArray) 

#print np.sum(varArray)

sum = 0;

for i in range (0,5):
	sum = sum + varArray[i];
print(sum) # sum = 99.9% for just 10 components!! 

#print pca.components_.shape
#print (pca.components_)

pca.n_components = 5
X_reduced = pca.fit_transform(dataset)
#print X_reduced.shape

np.savetxt("foo.csv", X_reduced, delimiter=",")
#==============================================================
#SELECT K-BEST

selectKbest = SelectKBest(f_regression, k=15)
k_best = selectKbest.fit_transform(dataset)

print selectKBest.scores_
print selectKBest.pvalues_

print k_best


