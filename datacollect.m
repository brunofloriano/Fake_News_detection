function [datain,dataout] = datacollect()

datatable = readtable('FACTCK.BR-master/fakebr.csv');
%[ndata,nfeatures] = size(datatable);

filename = "FACTCK.BR-master/fakebr.csv";
data = readtable(filename,'TextType','string');
%figure
histogram(data.Category);
xlabel("Class")
ylabel("Frequency")
title("Class Distribution")head(data)

url = table2array(datatable(:,1));
author = table2array(datatable(:,2));
datePublished = table2array(datatable(:,3));
claimReviewed = table2array(datatable(:,4));
reviewBody = table2array(datatable(:,5));
title = table2array(datatable(:,6));
ratingValue = table2array(datatable(:,7));
bestRating = table2array(datatable(:,8));
alternativeName = table2array(datatable(:,9));

% data = [reviewBody alternativeName];
% data = [url author datePublished claimReviewed reviewBody title ratingValue bestRating alternativeName];
% data = [claimReviewed reviewBody title ratingValue bestRating alternativeName];
% data = [claimReviewed reviewBody title ratingValue];
% data = table2array(datatable);

datain = [claimReviewed reviewBody title];
dataout = alternativeName;