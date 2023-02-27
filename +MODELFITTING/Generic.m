% General fitting class

classdef Generic < handle
    % This is a general fitting class for developing fit models for arbitary functions with
    % dynamical allocation of fit parameters versus constants. 
    properties
        ParamDefn 
        ParamDefnUpdated 
        ParamUnits 
        InitValues
        LowerBound
        UpperBound
        functionArg
        FitFunction
        XVariable
        XData
        YData
        FittingResults
    end
    
    
    methods
        
        function getFitSettings(obj, FitParams)
            % Wrapper for correctly calling all of the functions for setting up the fit parameters
            getParamsDefToFit(obj, FitParams);
            getInitialValues(obj, FitParams);
            getFunctionArgs(obj, FitParams);
        end
        
        function defineData(obj, XData, YData)
            % Pass the X and Y data to the fitting class.
            obj.XData = XData;
            obj.YData = YData;
        end
        
        function HighResFit = getHighResFit(obj, XDataNew)
            % get a higher resolution version of the fit results. 
            % Inputs:
            %   XDataNew: Array of the new x data for the new result
            HighResFit = obj.FitFunction(obj.FittingResults.Results, XDataNew);
        end

        function plotInitialGuess(obj)
            % Function for plotting the inital guess. 

            % make the fit x data twice as dense for plotting the fit 
            Xfitdata = linspace(min(obj.XData), max(obj.XData), length(obj.XData)*2);
            
            xVarIdx = strcmp(obj.ParamDefn, obj.XVariable);
            xAxisLabel = strcat('X data (', obj.ParamUnits(xVarIdx), ')');
            figure()
            plot(obj.XData, obj.YData, '.', 'color', 'k')
            xlabel(xAxisLabel)
            ylabel('Y data')
            hold on
            plot(Xfitdata, obj.FitFunction(obj.InitValues, Xfitdata), '-', 'Color','b')
            hold off
            
            legend('Data', 'Initial Guess')
            
        end


        function plotResults(obj)
            % Function for plotting the inital guess. 

            % make the fit x data twice as dense for plotting the fit 
            XDataNew = linspace(min(obj.XData), max(obj.XData), length(obj.XData)*4);
            
            HighResFit = obj.getHighResFit(XDataNew);

            xVarIdx = strcmp(obj.ParamDefn, obj.XVariable);
            xAxisLabel = strcat('X data (', obj.ParamUnits(xVarIdx), ')');
            figure()
            plot(obj.XData, obj.YData, '.', 'Color','k')
            xlabel(xAxisLabel)
            ylabel('Y data')
            hold on
            plot(XDataNew, HighResFit, '-', 'Color',[65, 105, 225]/255)
            hold off
            
            legend('Data', 'Initial guess')
            
        end
        
        function performFit(obj, FitAlgorithm)
            % This function actually performs the fit. 
            % Input:
            %       FitAlgorithm: is the type of fit that is performed.
            %       Currently only nlinfit is implemented. 
            if nargin <2 
                FitAlgorithm = "nlinfit";
            end
            
            if FitAlgorithm == "nlinfit"
                [Results, R, J, CovB, MSE, ErrorModelInfo] = ...
                    nlinfit(obj.XData, obj.YData, obj.FitFunction, obj.InitValues);
                obj.FittingResults.Results = Results;
                obj.FittingResults.Residuals = R;
                obj.FittingResults.Jacobian = J;
                obj.FittingResults.Covariance = CovB;
                obj.FittingResults.MeanSquareError = MSE;
                obj.FittingResults.ErrorModelInfo = ErrorModelInfo;

                obj.FittingResults.CI = nlparci(Results, R,'jacobian',J);
                
                % Get the standard error of the fitting parameters
                obj.FittingResults.StandardErrors = sqrt(diag(CovB));
                
                % Fit results
                obj.FittingResults.FitData = obj.FitFunction(Results, obj.XData);
                
            end
            
            obj.displayResults()
        end
        
        function getFunctionArgs(obj, FitParams)
           % Define the fitting parameters and the constants
           % This function writes the anomolous function for you based off
           % what parameters are fit paramerter and what are constants
            FittingParams = ismember(obj.ParamDefn, obj.ParamDefnUpdated);
            obj.functionArg = {};
            FitIdx = 1;
            for ii = 1:length(obj.ParamDefn)
                if FittingParams(ii)
                    obj.functionArg{ii} = strcat("v(", num2str(FitIdx), ")");
                    FitIdx = FitIdx +1;
                else
                    if  ~strcmp(obj.ParamDefn(ii), obj.XVariable) % Removes the x-data from the list
                        obj.functionArg{ii} = FitParams.InitValues.(obj.ParamDefn(ii));
                        if isnumeric(obj.functionArg{ii})
                            obj.functionArg{ii} = num2str(obj.functionArg{ii});
                        end
                    end
                end
            end 
            
        end
        
        function getInitialValues(obj, FitParams)
            % Define the intial parameters in the same order as the ParamDefnUpdated
            
            % Removes the x-data variable from the list
            idx = strcmp(obj.ParamDefnUpdated, obj.XVariable);
            % Define a new array without the ignored indices
            ParamDefnUpdated2 = obj.ParamDefnUpdated(~idx);
            % preallocate size
            obj.InitValues = zeros(1,length(ParamDefnUpdated2));
            % Iterate over the values and update the initial values. 
            for ii = 1:length(ParamDefnUpdated2)
                obj.InitValues(ii) = FitParams.InitValues.(ParamDefnUpdated2{ii});
            end
        
        end
        
        
        
        function getParamsDefToFit(obj, FitParams)
            % function takes the FitParams and defines a new set of parameters based off what you
            % want to fit. 
            idxs = zeros(1,length(obj.ParamDefn));
            for ii = 1:length(FitParams.ToFit)
                idxs = idxs + strcmp(obj.ParamDefn, FitParams.ToFit(ii));
            end

            obj.ParamDefnUpdated =  obj.ParamDefn(idxs>0);
        end
        


        function displayResults(obj)
            % This displays all the fit results based off the definition of the fit function paramater list and
            % unit list
            % Inputs:
            %       FitResults (Array): List of all the fit results in the ParamDefUpdated order. 
            %       FitErrors (Array): List of all the fit errors in the ParamDefUpdated order. 
            
            FitResults = obj.FittingResults.Results; 
            FitErrors = obj.FittingResults.StandardErrors; 
            ConfidenceInt = obj.FittingResults.CI;
            
            disp("Coefficients (with 95% confidence bounds)");

            for ii = 1:length(FitResults)
                idx = strcmp(obj.ParamDefn, obj.ParamDefnUpdated{ii});
                % Old version that displayed the standard error
%                 disp(strcat(obj.ParamDefnUpdated{ii}, " = ", num2str(FitResults(ii)), " (", ...
%                     num2str(FitErrors(ii)) ,")  (", obj.ParamUnits(idx), ")" ));

                disp(strcat(obj.ParamDefnUpdated{ii}, " = ", num2str(FitResults(ii)), " (", ...
                    num2str(ConfidenceInt(ii,1)) ,", ", num2str(ConfidenceInt(ii,2)) ,")  (", obj.ParamUnits(idx), ")" ));
            end
        end     
    end
end




