clear all;
clc;
%%
%Jiaying Shi
%shijy07@berkeley.edu
%%
%Load Data
% load 'sent_RoI_act_mean.mat'
load 'sent_RoI_act_mean.mat'
nIn=56;
nHid=39;
nOut=2;
% trainDataRaw=[train_pic1;train_pic2;train_pic4;train_pic5];
% trainLabel=[train_pic_label1;train_pic_label2;train_pic_label4;train_pic_label5];
trainDataRaw=[];
trainLabel=[];

for i=1:50
    trainDataRaw=[trainDataRaw;reshape(train_pic1(((i-1)*8+1):(i*8),:),1,56)];
    trainDataRaw=[trainDataRaw;reshape(train_pic2(((i-1)*8+1):(i*8),:),1,56)];
    trainDataRaw=[trainDataRaw;reshape(train_pic4(((i-1)*8+1):(i*8),:),1,56)];
    trainDataRaw=[trainDataRaw;reshape(train_pic5(((i-1)*8+1):(i*8),:),1,56)];
    trainLabel=[trainLabel;train_pic_label1(i*8)*ones(4,1)];
    %     trainDataRaw=[trainDataRaw;reshape(train_pic6(((i-1)*8+1):(i*8),:),1,56)];
%     if mod(i,2)==1
%         trainLabel=[trainLabel;ones(4,1)];
%     else
%       trainLabel=[trainLabel;2*ones(4,1)];
%     end
end
for i=1:49
   trainDataRaw=[trainDataRaw;reshape(train_pic3(((i-1)*8+1):(i*8),:),1,56)];
   trainLabel=[trainLabel;train_pic_label3(i*8)]; 
end

n=size(trainLabel,1);
nTest=50;
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
nBS=20;
nTrain=length(train_Label);
%%
%
predictLabel=zeros(nTest,1);
nnOutput=zeros(nTest,2);
weight=[];
for bs=1:nBS
maxIter=5000;
stepSize=1;
nAvg=100;
indxBS=randsample(nTrain,100);
train_DataBS=train_Data(indxBS,:);
train_LabelBS=train_Label(indxBS);

indxF=randsample(56,48);
train_DataBS=train_DataBS(:,indxF);
test_DataBS=test_Data(:,indxF);
test_LabelBS=test_Label;
validationData=[];
validationLabel=[];
for j=1:nTrain
    if sum(indxBS==j)==0
        validationData=[validationData;train_Data(j,indxF)];
        validationLabel=[validationLabel;train_Label(j)];     
    end
end
tic;
[W1BS,W2BS,accuracyClassification,trainError]=trainNN(train_DataBS,train_LabelBS,nHid,nOut,2,maxIter,stepSize,nAvg);
toc;
[errorRateV,predictLabelBSV,nnOutputBSV]= predictNN(W1BS,W2BS,validationData,validationLabel);
[errorRate,predictLabelBS,nnOutputBS]= predictNN(W1BS,W2BS,test_DataBS,test_LabelBS);
weight=[weight;1/errorRateV];
nnOutput(:,:,bs)=nnOutputBS;
end
nnO=zeros(nTest,2);
for bs=1:nBS
    nnO=nnO+weight(bs)/sum(weight)*nnOutput(:,:,bs);
end
[maxOut, predictLabel] = max(nnO, [], 2);
errorRate=sum(predictLabel~=test_Label)/nTest;
% f1=plot(trainError);
% title('Cross-Entropy Error over Iteration');
% xlabel('Iteration');
% ylabel('Cross-Entropy Error');
% % saveas(f1,'CE.jpg');
% 
% f2=figure;
% plot(accuracyClassification);
% title('Classification Accuracy with Cross-Entropy Error');
% xlabel('Iteration');
% ylabel('Classification Accuracy');
% % saveas(f2,'CE_accu.jpg');
