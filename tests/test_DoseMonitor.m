% test_DoseMonitor

cDirThis = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'src')))
addpath(genpath(fullfile(cDirThis, '..', 'vendor', 'ssh2_v2_m1_r7')))


mdm = cxro.DoseMonitor();
lSuccess = mdm.connect();
[cValue, lSuccess] = mdm.read();
cValue
[cValue, lSuccess] = mdm.read();
cValue
[cTiming, cIncrement, dSamples, dCounts] = mdm.getValuesFromDataWord(cValue);
lSuccess = mdm.disconnect();
