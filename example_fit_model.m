%% Example fitting test for demonstrating how to use model fitting. 
close all;
clear;
clc;

%% Load Data
% Load the test dataset 
load('test_data\lorentzian_sub_data.mat');


%% Perform Fitting
% Create an instance of the class for each dataset that you plan to fit. In
% this case we will fit two different spectra, so we define a FIT and FIT2.
FIT = MODELFITTING.ModelFeedbackSpectrum;
FIT2 = MODELFITTING.ModelFeedbackSpectrum;

% Next we want to define what parameters we will actually fit. In the model
% itself we have defined what parameters actually exist. 
%
% ParamDefn = ["Central_freq", "background_counts", "contrast", ...
%                "width", "splitting"];
%
% So we define a list of strings that will be checked against this list to
% define the fit itself. In this case the parameter splitting is known as
% it was defined in the experiment so we want to set this as a constant
% rather than a fit parameter. So we leave splitting out of the ToFit list.

FitParams.ToFit = ["Central_freq", "background_counts", "contrast", "width"];


% Now we define the initial values for the fit. If one of the parameters is
% a constant then this is the permanant value for this parameter. 
FitParams.InitValues.Central_freq = 2918; 
FitParams.InitValues.background_counts = 1e6; 
FitParams.InitValues.contrast = 0.01;
FitParams.InitValues.width = 10;
FitParams.InitValues.splitting = 15;


%%  Define the data, settings and funtion
% Pass the data that we want to fit to the fitting class through the
% defineData function
FIT.defineData(dataset.xdata, dataset.ydata1)
FIT2.defineData(dataset.xdata, dataset.ydata2)

% Pass the FitParams to the class so it knows what to fit
FIT.getFitSettings(FitParams)
FIT2.getFitSettings(FitParams)

% Creates the anomlous function that is used in the fit
FIT.defineFitFunction()
FIT2.defineFitFunction()


% Plot init guesses
FIT.plotInitialGuess()
FIT2.plotInitialGuess()

%% Perform the fitting
FIT.performFit()
FIT2.performFit()

%% Get all the fitting results
FitResults = FIT.FittingResults;
FitResults2 = FIT2.FittingResults;


%% Plot the results

FIT.plotResults()
FIT2.plotResults()

