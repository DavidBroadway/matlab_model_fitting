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
