%% Simple test of hmmDiscreteFitEm
% We compare how well the true model can decode a sequence, compared to a
% model learned via EM using the best permutation of the labels. 
%PMTKslow
%% Define the generating model
setSeed(0);
nHidStates = 4; 
trueModel.emission = [1/6  1/6   1/6   1/6   1/6   1/6  ;  
                     1/10  1/10  1/10  1/10  1/10  5/10 
                     2/6   1/6   1/6   16    1/12  1/12
                     7/12   1/12  1/12  1/12  1/12 1/12];  
    
trueModel.A = [0.6 0.15 0.20 0.05;
              0.10 0.70 0.15 0.05
              0.10 0.30 0.10 0.50
              0.30 0.10 0.30 0.30];

trueModel.pi = [0.8 0.1 0.1 0];
trueModel.type = 'discrete';
%% Sample
len = 10000;
[observed, hidden] = hmmSample(trueModel, len);
hidden = hidden{1};
%% Learn the model using EM with random restarts
nrestarts = 10;
modelEM = hmmFit(observed, nHidStates, 'discrete', ...
    'convTol', 1e-5, 'nRandomRestarts', nrestarts, 'verbose', true);

%% How different are the respective log probabilities?
fprintf('trueModel LL: %g\n', hmmLogprob(trueModel, observed));
fprintf('emModel LL: %g\n', hmmLogprob(modelEM, observed)); 

%% Decode using true model
decodedFromTrueViterbi = hmmEstState(trueModel, observed);
decodedFromTrueViterbi = bestPermutation(decodedFromTrueViterbi, hidden);
trueModelViterbiError = mean(decodedFromTrueViterbi ~= hidden)

decodedFromTrueMaxMarg = maxidx(hmmInferState(trueModel, observed), [], 1);
decodedFromTrueMaxMarg = bestPermutation(decodedFromTrueMaxMarg, hidden);
trueModelMaxMargError = mean(decodedFromTrueMaxMarg ~= hidden)

%% Decode using the EM model
decodedFromEMviterbi = hmmEstState(modelEM, observed);
decodedFromEMviterbi = bestPermutation(decodedFromEMviterbi, hidden);

emModelViterbiError = mean(decodedFromEMviterbi ~= hidden)

decodedFromEMmaxMarg = maxidx(hmmInferState(modelEM, observed), [], 1);
decodedFromEMmaxMarg = bestPermutation(decodedFromEMmaxMarg, hidden);

emModelMaxMargError = mean(decodedFromEMmaxMarg ~= hidden)


