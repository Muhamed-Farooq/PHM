function [pc] = calcepca(data, varargin)

% calcepca(data, 'IsLabel', logical(true or false), 'HealthyDataOnly', logical, 'AllData', logical, 'ExplainedVaiance',
% string, 'FirstNPCs', string, 'PlotXDim', string, 'PlotYDim', string);

p = inputParser;
p.CaseSensitive = false;    % Names are not sensitive to case: 'a' matches 'A'

defaultIsLabel = 'false';
defaultHealthyDataOnly = 'false';
defaultAllDataWithLabel= 'false';
defaultExplainedVariance = '';
defaultFirstNPCs = '';
defaultPlotXDim = 'PC1';
defaultPlotYDim = 'PC2';

addRequired(p, 'data', @ismatrix);
addParameter(p, 'islabel', defaultIsLabel, @ischar);
addParameter(p, 'healthydataonly', defaultHealthyDataOnly, @ischar);
addParameter(p, 'alldatawithlabel', defaultAllDataWithLabel, @ischar);
addParameter(p, 'explainedvariance', defaultExplainedVariance, @ischar);
addParameter(p, 'firstnpcs', defaultFirstNPCs, @ischar);
addParameter(p, 'plotxdim', defaultPlotXDim, @ischar);
addParameter(p, 'plotydim', defaultPlotYDim, @ischar);
parse(p, data, varargin{:});

% inputdata: a M x N matrix, where M is # of observations and N is # of
%            features (or variables). Note that if islabel=true, the last column of the input data is class label.
inputdata = p.Results.data;
if strcmp(p.Results.islabel, 'true') & strcmp(p.Results.healthydataonly, 'true')
    ndimensions = size(inputdata,2)-1;
    label = inputdata(:,end);
    tmpdata = inputdata(:,label==0);
    dataforpca = tmpdata(:,1:ndimensions);
elseif strcmp(p.Results.islabel, 'true') & strcmp(p.Results.alldatawithlabel, 'true')
    ndimensions = size(inputdata,2)-1;
    dataforpca = inputdata(:,1:ndimensions);    
elseif ~strcmp(p.Results.islabel, 'true') & ~strcmp(p.Results.healthydataonly, 'true') & ~strcmp(p.Results.alldatawithlabel, 'true')
    ndimensions = size(inputdata,2);
    dataforpca = inputdata;
end

%% PCA
[pc, score, latent, tsquare] =  pca(dataforpca);

% pcvar: % of PC variances
% cuvar: % of PC's cumulative variance
pcvar = 100*(latent./sum(latent));
pccuvar = 100*(cumsum(latent)./sum(latent));

explainedvariance = str2num(p.Results.explainedvariance);
firstnpcs = str2num(p.Results.firstnpcs);
plotxdim = str2num(p.Results.plotxdim(isstrprop(p.Results.plotxdim, 'digit')));
plotydim = str2num(p.Results.plotydim(isstrprop(p.Results.plotydim, 'digit')));
plotpcs = [plotxdim plotydim];

% pcvar: % of PC variances
% cuvar: % of PC's cumulative variance
% lastpcidx: The last PC's index that can make PC's cumulative variance exceeds the explained variance
if ~isempty(explainedvariance) & isempty(firstnpcs) % find PCs based on the provded explained variance    
    lastpcidx = min(find(pccuvar>=explainedvariance));
    pc = pc(:,1:lastpcidx);
elseif isempty(explainedvariance) & ~isempty(firstnpcs) % find N number of PCs, where N is the number specified by the user
    pc = pc(:,1:firstnpcs);
end

% plot cumulative variance of principal components
figure,
bar([1: length(pcvar)], pcvar);
hold on, plot([1: length(pcvar)], pccuvar, 'ro-');
xlabel('PC'), ylabel('Variance [%]');
legend('% of PC Variance', '% of PC Cumulative Variance');

% plot projected data on principal components
calcepcaplot(inputdata(:,1:ndimensions), pc, plotpcs);

% save pc
saveFolder = 'C:\CALCE-PHM\PCA';
if ~exist(saveFolder, 'dir');
    mkdir(saveFolder);
end

csvwrite([saveFolder '\pc.csv'], pc);

end


