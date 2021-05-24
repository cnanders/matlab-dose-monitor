% test_DoseMonitor

cDirThis = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'src')))
addpath(genpath(fullfile(cDirThis, '..', 'vendor',  'ssh2_v2_m1_r7')))

HOSTNAME = '192.168.20.60';
USERNAME = 'pi';
PASSWORD = 'ilbl1201!';
        
ssh2_conn = ssh2_config(HOSTNAME,USERNAME,PASSWORD);
ssh2_conn = ssh2_command(ssh2_conn, 'ls -al');
ssh2_conn = ssh2_close(ssh2_conn); %will call ssh2.m and run command and then close connection
