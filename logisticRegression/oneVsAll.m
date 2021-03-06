function [all_theta, cost] = oneVsAll(X, y, num_labels, lambda, reg)
%ONEVSALL trains multiple logistic regression classifiers and returns all
%classifiers in a matrix all_theta
%   [all_theta] = ONEVSALL(X, y, num_labels, lambda) trains multiple
%   (num_labels) logistic regression classifiers and returns each of these classifiers
%   in a matrix all_theta, where i-th row of all_theta corresponds 
%   to the classifier for label i

% Some useful variables
m = size(X, 1); %number of examples
n = size(X, 2); %number of features

% You need to return the following variables correctly 
all_theta = zeros(num_labels, n + 1);

% Add ones to the X data matrix
X = [ones(m, 1), X];

%For this assignment, we recommend using fmincg to optimize the cost function. 
%Use a for-loop (for c = 1:num_labels) to loop over the different classes.
% fmincg works similarly to fminunc, but is more efficient when
%dealing with large number of parameters.
% Set Initial theta
initial_theta = zeros(n+1,1);

cost = zeros(50, num_labels);

iter = 5000;

options = optimset('GradObj', 'on', 'MaxIter', 400);
  for c = 1:num_labels
           
       if(reg==0)
           [theta, cost] = fminunc(@(t)(costFunction(t, X, y==c)), initial_theta, options);
       else
           [theta, cost] = fminunc(@(t)(costFunctionReg(t, X, y==c, lambda)), initial_theta, options);
       end
       
     %Save the parameters of each binary classifier in one raw of matrix all_theta
     all_theta(c,:)=theta';
     
  end

end
