function deco_displayresults(xaxisindex, data, titlestr, xaxessstr, yaxesstr)

figure;
plot(xaxisindex, data);
xlabel(xaxessstr);
ylabel(yaxesstr);
title(titlestr);

end