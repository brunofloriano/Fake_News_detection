clear; close all; clc;

% DATA COLLECT
filename = "FACTCK.BR-master/fakebr.csv";
data = readtable(filename,'TextType','string');
head(data)

data.Category = categorical(data.alternativeName);
data.Category = preprocess(data.Category);

% SHOW CATEGORIES
figure
histogram(data.Category);
xlabel("Class")
ylabel("Frequency")
title("Class Distribution")


% PARTITIONATE TRAIN/TEST/VALIDATION
cvp = cvpartition(data.Category,'Holdout',0.2);
dataTrain = data(training(cvp),:);
dataValidation = data(test(cvp),:);

cvp2 = cvpartition(dataTrain.Category,'Holdout',0.25);
dataTrain = data(training(cvp2),:);
dataTest = data(test(cvp2),:);

% IN/OUT
% textDataTrain = dataTrain.reviewBody;
% textDataValidation = dataValidation.reviewBody;
% textDataTest = dataTest.reviewBody;

textDataTrain = dataTrain.claimReviewed;
textDataValidation = dataValidation.claimReviewed;
textDataTest = dataTest.claimReviewed;

YTrain = dataTrain.Category;
YValidation = dataValidation.Category;
YTest = dataTest.Category;

% WORD CLOUD
% figure
% wordcloud(textDataTrain);
% title("Training Data")

% TEXT PROCESS
documentsTrain = preprocessText(textDataTrain);
documentsValidation = preprocessText(textDataValidation);
documentsTest = preprocessText(textDataTest);

%documentsTrain(1:5) % Apenas para visualização

% WORD ENCODING
enc = wordEncoding(documentsTrain);

% documentLengths = doclength(documentsTrain);
% figure
% histogram(documentLengths)
% title("Document Lengths")
% xlabel("Length")
% ylabel("Number of Documents")

sequenceLength = 150;
XTrain = doc2sequence(enc,documentsTrain,'Length',sequenceLength);
XTrain(1:5)

XValidation = doc2sequence(enc,documentsValidation,'Length',sequenceLength);
XTest = doc2sequence(enc,documentsTest,'Length',sequenceLength);

inputSize = 1;
embeddingDimension = 50;
numHiddenUnits = 20;

numWords = enc.NumWords;
numClasses = numel(categories(YTrain));

layers = [ ...
    sequenceInputLayer(inputSize)
    wordEmbeddingLayer(embeddingDimension,numWords)
    lstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MiniBatchSize',16, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XValidation,YValidation}, ...
    'Plots','training-progress', ...
    'Verbose',false);

epochs = 20; %10:10:80;
for i = 1:length(epochs)
    options.MaxEpochs = epochs(i);
    % TRAIN
    net = trainNetwork(XTrain,YTrain,layers,options);
    
    labelsValidation = classify(net,XValidation);
    error = double(labelsValidation ~= YValidation);
    percentage_error(i) = sum(error)/length(error)*100;
end

plot(epochs,percentage_error)
xlabel('Epochs')
ylabel('Error (%)')

% TEST
labelsTest = classify(net,XTest);
error = double(labelsTest ~= YTest);
percentage_error_test = sum(error)/length(error)*100

falso_verdadeiro = 0;
falso_falso = 0;
falso_semi = 0;

for i = 1:length(error)
    if error(i) == 1
        if labelsTest(i) == 'Verdadeiro'
            falso_verdadeiro = falso_verdadeiro + 1;
        elseif labelsTest(i) == 'Falso'
            falso_falso = falso_falso + 1;
        elseif labelsTest(i) == 'Semi-Verdadeiro'
            falso_semi = falso_semi + 1;
        end
    end
end

nverdadeiro = sum( double(labelsTest == 'Verdadeiro') );
nfalso = sum( double(labelsTest == 'Falso') );
nsemi = sum( double(labelsTest == 'Semi-Verdadeiro') );

rnverdadeiro = sum( double(YTest == 'Verdadeiro') );
rnfalso = sum( double(YTest == 'Falso') );
rnsemi = sum( double(YTest == 'Semi-Verdadeiro') );

precisao_verdadeiro = (nverdadeiro - falso_verdadeiro)/(nverdadeiro)*100;
precisao_falso = (nfalso - falso_falso)/(nfalso)*100;
precisao_semi = (nsemi - falso_semi)/(nsemi)*100;

recall_verdadeiro = (nverdadeiro - falso_verdadeiro)/(rnverdadeiro)*100;
recall_falso = (nfalso - falso_falso)/(rnfalso)*100;
recall_semi = (nsemi - falso_semi)/(rnsemi)*100;

% SAVE
save_folder = 'results\';
save_mainname = 'fakebr ';

clocktime = clock;
time_now = [num2str(clocktime(1)) '-' num2str(clocktime(2)) '-' num2str(clocktime(3)) '-' num2str(clocktime(4)) '-' num2str(clocktime(5))];
savefolderlocal = [save_folder '\' save_mainname time_now];
save_file = [savefolderlocal '\' save_mainname  time_now '.mat'];

mkdir(savefolderlocal);
save(save_file);
saveas(gcf,[savefolderlocal '\' save_mainname  time_now '.jpg']);