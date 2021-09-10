% test_DoseMonitor

cDirThis = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'src')))
addpath(genpath(fullfile(cDirThis, '..', 'vendor')))


mdm = cxro.DoseMonitor();
lSuccess = mdm.connect();

%{
[cValue, lSuccess] = mdm.read();
cValue
[cValue, lSuccess] = mdm.read();
cValue
[cTiming, cIncrement, dSamples, dCounts] = mdm.getValuesFromDataWord(cValue);
%}

dCounts = mdm.getCounts()
lSuccess = mdm.disconnect();
