# matlab_model_fitting
Method for dynamic setting of fitting parameters and constants in fits

The idea behind this package is to minimise the amount of times you need to define new fitting functions just to test the influence of certain parameters on your fitting. The package defines a generic class that deals with defining the anonymous function for you based off what parameters you want to fit and what parameters you want to hold as a constant. 

## Adding the package to the correct directory
To use the package add the folder to your working directory and then you can access the models anywhere by using the package name, MODELFITTING.YourModel. This is to help keep your namespace safe from all the models you might define. 

## Making a model
When making a you should follow the example that is given. I have tried to make it as easy as possible. You have to define your class as a child of the generic model class
```
classdef ModelFeedbackSpectrum < MODELFITTING.Generic
```
Then you need to define three functions. 
The initialisation function that has the same name as the model class
```
function obj = ModelFeedbackSpectrum()
    % This function is the init function call
    obj.ParamDefn = ["freq_list", "Central_freq", "background_counts", "contrast", ...
        "width", "splitting"];
    obj.ParamUnits =["MHz", "MHz", "cps", "fraction", "MHz", "MHz"];
    obj.XVariable = "freq_list";
end
```
ParamDefn: is a list of the names of all the parameters that will be checked against for defining the fit parameters, this includes the x-data name. 
ParamUnits: Is the units of all of the parameters. This is only used for displaying the results so it is not critical but is nice to have. 
XVariable: Defines the name of the x-data

Then we need to define the function that will define the fit function for us.  

```
function defineFitFunction(obj)
    % Define the x-vector
    obj.functionArg{1} = "x";
    functionArg = obj.functionArg;

    % Define the fit in terms of the fitting parameters
    obj.FitFunction = @(v, x) obj.model(...
        eval(functionArg{1}), ...
        eval(functionArg{2}), ...
        eval(functionArg{3}), ...
        eval(functionArg{4}), ...
        eval(functionArg{5}), ...
        eval(functionArg{6}) ...
                            ); 
end
```
In this function you need to define which argument in your model is the x-variable. I would recomend just defining this as the first parameter all of the time. Then you need to write a call to the model function that contains enough arguments. Note that you need the eval function for each functionArg to make this work correctly. 

Finally you need to define your model itself. This can take any form that you want. In the example it is given as
```
function signal = model(obj, freq_list, Central_freq, ...
        background_counts, contrast, width, splitting)
    %Function for defining the signal which is the model 

    Counts1 = obj.lorentzian(freq_list, background_counts, Central_freq - 0.5*splitting, width, contrast);
    Counts2 = obj.lorentzian(freq_list, background_counts, Central_freq + 0.5*splitting, width, contrast);
    signal = Counts1 - Counts2;
end



function Counts = lorentzian(obj, freq_list, background_counts, Central_freq, width, contrast)
        %Function for defining a lorenztian ODMR signal with shot noise. 
        Counts =  background_counts * (1 - contrast ./ (1 + (freq_list - Central_freq).^2/ (0.5*width).^2));
end

```



