function fitresult = createFit(powerMeasure, PadcCalc)
%CREATEFIT(POWERMEASURE,PADCCALC)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : powerMeasure
%      Y Output: PadcCalc
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 21-Jan-2022 14:46:09


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( powerMeasure, PadcCalc );

% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Lower = [-Inf 0];
opts.Robust = 'Bisquare';
opts.Upper = [Inf 0];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'PadcCalc vs. powerMeasure', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % Label axes
% xlabel( 'powerMeasure', 'Interpreter', 'none' );
% ylabel( 'PadcCalc', 'Interpreter', 'none' );
% grid on


