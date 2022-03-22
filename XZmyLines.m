function fitresult = myLines(x,y)
% Построение прямой Реальной
[xData, yData] = prepareCurveData( x, y);
% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'Bisquare';
% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
end