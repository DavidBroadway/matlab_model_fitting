% Example of how to define a new model
% This example is a signal that is define by the subtraction of two offset
% lorentzians. 


classdef ModelFeedbackSpectrum < MODELFITTING.Generic
    
    properties
        
    end
    
    methods

        function obj = ModelFeedbackSpectrum()
            % This function is the init function call
            obj.ParamDefn = ["freq_list", "Central_freq", "background_counts", "contrast", ...
                "width", "splitting"];
            obj.ParamUnits =["MHz", "MHz", "cps", "fraction", "MHz", "MHz"];
            obj.XVariable = "freq_list";
        end

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
    end
        

end
