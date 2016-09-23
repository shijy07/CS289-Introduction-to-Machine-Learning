function [W1,W2,accuracyClassification,trainError]=trainNNcog(trainData,trainLabel,nHid,nOut,costFunc,maxIter,stepSize,nAvg)
%TRAINNN train neural network
%costFunc=1 MSE
%costFunc=2 crossEntropy
trainError=[];
accuracyClassification=[];
nTrain=size(trainData,1);
nIn=size(trainData,2);
epsilon1 = 0.2568;
epsilon2 =0.4027;
% epsilon1 = 0.0542;
% epsilon2 =0.0778;
W1 = unifrnd(-1*epsilon1,epsilon1,nIn+1,nHid);
W2 = unifrnd(-1*epsilon2,epsilon2,nHid+1, nOut);
for i=1:maxIter
%     step=stepSize/(log(i+1)+1)/0.1;
    step=stepSize/nTrain;
%     if(i>1000)
%         step=stepSize/i^0.5;
%     else
%     step=stepSize;
%     end
    k=randsample(nTrain,nAvg);
    for j=1:nAvg
        
        data=[trainData(k(j),:),1];
        label=trainLabel(k(j),:);
        hiddenIn = tanh(data* W1);
        hiddenData = [hiddenIn,1];
        predict=sigmf(hiddenData*W2,[1,0]);
        labelOut=zeros(1,nOut);
        labelOut(label)=1;
        if(costFunc==1)
            dW2=(predict-labelOut).*predict.*(1-predict);
        end
        if(costFunc==2)
            dW2=predict-labelOut;
        end
        W2=W2-step.*(hiddenData')*dW2;
        dW1 = data' * (dW2 * W2(1:nHid,:)' .* (1 - (hiddenData(:,1:nHid)').^2)');
        W1 = W1 - step* dW1;
    end
    train=[trainData,ones(nTrain,1)];
    hiddenLayerIn = tanh(train * W1);
    hiddenLayer=[hiddenLayerIn,ones(nTrain,1)];
    predictL = sigmf(hiddenLayer * W2,[1,0]);
    trainError = [trainError,OBJ_Error(predictL,trainLabel,nOut,costFunc)];
    [out,predictLabels]= max(predictL,[],2);
    accuracyClassification=[accuracyClassification, sum(predictLabels==trainLabel)/nTrain];
%     if(sum(predictLabels==trainLabel)/nTrain>0.9999)
%         break;
%     end
end

end