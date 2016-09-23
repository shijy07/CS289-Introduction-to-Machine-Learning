clear all;
clc;
%%
%Jiaying Shi
%shijy07@berkeley.edu
%%
%Load Data
load 'sent_RoI_act_mean.mat'
nIn=56;
nHid=35;
nOut=2;
% trainDataRaw=[train_pic1;train_pic2;train_pic4;train_pic5];
% trainLabel=[train_pic_label1;train_pic_label2;train_pic_label4;train_pic_label5];
trainDataRaw=[];
trainLabel=[];
for i=1:100
    trainDataRaw=[trainDataRaw;reshape(train_pic1(((i-1)*8+1):(i*8),:),1,56)];
    trainDataRaw=[trainDataRaw;reshape(train_pic2(((i-1)*8+1):(i*8),:),1,56)];
    trainDataRaw=[trainDataRaw;reshape(train_pic4(((i-1)*8+1):(i*8),:),1,56)];
    trainDataRaw=[trainDataRaw;reshape(train_pic5(((i-1)*8+1):(i*8),:),1,56)];
     trainDataRaw=[trainDataRaw;reshape(train_pic6(((i-1)*8+1):(i*8),:),1,56)];
    if mod(i,2)==1
        trainLabel=[trainLabel;ones(5,1)];
    else
      trainLabel=[trainLabel;2*ones(5,1)];
    end
end

n=size(trainLabel,1);
nTest=150;
%%
%Preprocess
indx=randsample(n,n);
trainData=trainDataRaw(indx,:);
trainLabel=trainLabel(indx);
%%
%reshape data
meanTrain=mean(trainData);
stdTrain=std(trainData);
for i=1:size(trainData,2);
    if(stdTrain(i)~=0)
        trainData(:,i)=(trainData(:,i)-meanTrain(i))/stdTrain(i);
    end
end
%%
%get validation data
train_Data=trainData((nTest+1):n,:);
train_Label=trainLabel((nTest+1):n);
test_Data=trainData(1:nTest,:);
test_Label=trainLabel(1:nTest);

%%
%
maxIter=5000;
stepSize=1;
nAvg=200;
tic;
[W1,W2,accuracyClassification,trainError]=trainNN(train_Data,train_Label,nHid,nOut,2,maxIter,stepSize,nAvg);
toc;
[errorRate,predictLabel,nnOutput]= predictNN(W1,W2,test_Data,test_Label);
f1=plot(trainError);
title('Cross-Entropy Error over Iteration');
xlabel('Iteration');
ylabel('Cross-Entropy Error');
% saveas(f1,'CE.jpg');

f2=figure;
plot(accuracyClassification);
title('Classification Accuracy with Cross-Entropy Error');
xlabel('Iteration');
ylabel('Classification Accuracy');
% saveas(f2,'CE_accu.jpg');
