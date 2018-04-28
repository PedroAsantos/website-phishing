function [J, grad] = costFunction(theta, X, y)
%COSTFUNCTION Compute cost and gradient for logistic regression
%   J = COSTFUNCTION(theta, X, y) computes the cost of using theta as the
%   parameter for logistic regression and the gradient of the cost
%   w.r.t. to the parameters.

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost J of a particular choice of theta.
% Note: grad should have the same dimensions as theta

e = exp(1); % this line is not nececessary
h= 1./(1+exp(-X*theta));

J=sum(-y.*log(h)-(1-y).*log(1-h))/m;
grad=(1/m)*(h-y)'*X;

% =============================================================
end