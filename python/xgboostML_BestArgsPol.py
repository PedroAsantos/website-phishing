from numpy import loadtxt
from xgboost import XGBClassifier
from xgboost import plot_importance
from sklearn.model_selection import train_test_split
from matplotlib import pyplot
from sklearn.metrics import accuracy_score
from numpy import sort
from sklearn.feature_selection import SelectFromModel
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt

import sys
import numpy as np
print("------------------------------------------------")
print("to test this algoithm using polynomial feautures use as argument -> -p as flag with the number of feautures that you want use -> -p 2")


usePolynomialFeatures=False
useTest=False
if len(sys.argv)>1:
	if str(sys.argv[1])=='-t':
		useTest=True
if len(sys.argv)>2:
	if str(sys.argv[1])=='-p':
		usePolynomialFeatures=True
		numberOfPolynomialFeautures=int(str(sys.argv[2]))




data = loadtxt('PhishingData.txt', delimiter=",")



# split data into X and y
X = data[:,0:9]
y = data[:,9]

if usePolynomialFeatures:
	poly = PolynomialFeatures(numberOfPolynomialFeautures)
	X=poly.fit_transform(X)
	print(X[1].size)


seed = 7
testAndCrossValidation_size = 0.45
X_train, X_crossAndTest, y_train, y_crossAndTest = train_test_split(X, y, test_size=testAndCrossValidation_size, shuffle=False)
test_size=0.428571429
X_CrossValidation, X_test, y_CrossValidation, y_test = train_test_split(X_crossAndTest, y_crossAndTest, test_size=test_size, shuffle=False)


max_depth=8 #5  #=4
learning_rate=0.1 #0.2  #=0.5
n_estimator=50 #80 #=80   n conlusion
#silent=False #=false      100%
min_child_weight=3  #1  #=3


# fit model no training data
model = XGBClassifier(max_depth=max_depth,learning_rate=learning_rate,n_estimator=n_estimator,min_child_weight=min_child_weight)
#model = XGBClassifier()
if useTest:
	testAndCrossValidation_size = 0.15
	X_train, X_crossAndTest, y_train, y_crossAndTest = train_test_split(X, y, test_size=testAndCrossValidation_size, shuffle=False)
	model.fit(X_train,y_train)
else:
	model.fit(X_train, y_train)
print(model)
#print(model)
if useTest:
	print(X_train.size)
	y_pred = model.predict(X_test)
	predictions = [round(value) for value in y_pred]
	accuracy = accuracy_score(y_test, predictions)
	#confusion_matrix(y_test, predictions)
else:
	y_pred = model.predict(X_CrossValidation)
	predictions = [round(value) for value in y_pred]
	accuracy = accuracy_score(y_CrossValidation, predictions)
	#confusion_matrix(y_CrossValidation, predictions)




print("Accuracy: %f" % (accuracy*100.0))
	# plot the importance of feautures
plot_importance(model)
pyplot.show()


#make predictions
#y_pred = model.predict(X_test)
#predictions = [round(value) for value in y_pred]
#verify predictions
#accuracy = accuracy_score(y_test, predictions)
#print("Accuracy: %.2f%%" % (accuracy * 100.0))

########################################################train data by test each subset of features by importance.
accuracys=[]
sizeModel=[]
thresholds = sort(model.feature_importances_)
for thresh in thresholds:
	# select features using threshold
	selection = SelectFromModel(model, threshold=thresh, prefit=True)
	select_X_train = selection.transform(X_train)
	# train model
	selection_model = XGBClassifier(max_depth=max_depth,learning_rate=learning_rate,n_estimator=n_estimator,min_child_weight=min_child_weight)
	selection_model.fit(select_X_train, y_train)
	# eval model
	select_X_test = selection.transform(X_CrossValidation)
	y_pred = selection_model.predict(select_X_test)
	predictions = [round(value) for value in y_pred]
	accuracy = accuracy_score(y_CrossValidation, predictions)
	accuracys.append(accuracy*100)
	sizeModel.append(select_X_train.shape[1])
	print("Thresh=%.3f, n=%d, Accuracy: %f" % (thresh, select_X_train.shape[1], accuracy*100.0))
plt.plot(sizeModel,accuracys)
plt.title('Gradient Boosted Trees - Best Values') # subplot 211 title
t = plt.xlabel('Accuracy', fontsize=12)
t = plt.ylabel('Number of Feautures', fontsize=12)
plt.show()
while len(accuracys)>0:
	print(max(accuracys))
	indMA = accuracys.index(max(accuracys))
	print(sizeModel[indMA])
	accuracys.pop(indMA)
	sizeModel.pop(indMA)
