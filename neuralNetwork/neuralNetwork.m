clear ; close all; clc
% =============== Load the data ========================

load('training.mat');
load('labels.mat');

X = X + 2;
y = y + 2;

m = size(X,1);
training_length = round(0.65*m);
crossValidation_length = round(0.2*m);

%Divide data into training, cross validation, and testing sets
train_x = X([1:training_length],:); %First 946 rows for training (aproximatly 70% of the dataset)
train_y = y([1:training_length],:);

cv_x = X([training_length+1:training_length+crossValidation_length],:); %Next rows for cross validation
cv_y = y([training_length+1:training_length+crossValidation_length],:);

test_x = X([training_length+crossValidation_length+1:m],:); %Last rows for testing
test_y = y([training_length+crossValidation_length+1:m],:);

RandStream.setGlobalStream (RandStream ('mrg32k3a','Seed', 1234)); % Use always the same seed

% ================ Initializing Pameters ================
%fprintf('\nInitializing Neural Network Parameters ...\n')

input_layer_size = 9;
hidden_layer_size = 2;
num_labels = 3;

initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);

% Unroll parameters
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

% =============== Training neural network ===============
 

lambda = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.5, 2, 2.5, 3];
result = []
%fprintf('\nTraining Neural Network... \n')
for i=1:length(lambda)
    fprintf('Iteration %f\n', i);

    options = optimset('MaxIter', 43);

    %  You should also try different values of lambda
   % lambda = 1;

    % Create "short hand" for the cost function to be minimized
    costFunction = @(p) nnCostFunction(p, ...
                                       input_layer_size, ...
                                       hidden_layer_size, ...
                                       num_labels, train_x, train_y, lambda(i));

    [nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

    % Obtain Theta1 and Theta2 back from nn_params
    Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                     hidden_layer_size, (input_layer_size + 1));

    Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                     num_labels, (hidden_layer_size + 1));

    % ================= Part 9: Predict =================

    pred = predict(Theta1, Theta2, cv_x);
    result(i) = mean(double(pred(:) == cv_y)) * 100;
end

%      fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred(:) == cv_y)) * 100);
plot(result);
ylim([0 100]);
xlim([0 3]);
grid on;
title('Neural network performance');
xlabel('Lambda');
ylabel('Accuracy');

