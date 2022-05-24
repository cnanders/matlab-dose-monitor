classdef DoseMonitor < cxro.DoseMonitorAbstract
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        

        
        cHost = '192.168.20.60'
        cUser = 'pi'
        cPassword = 'ilbl1201!'

        cPathData = '/home/pi/CXRO-DoseMonitor/data/DoseValue.txt'
        cPathStartScript = '/home/pi/CXRO-DoseMonitor/get_DoseData.py'
        
        
        % storage for the SSH2 connection (through external library)
        % Uses  Improved Matlab interface for SSH2/SFTP/SCP (supports public key) using the Ganymed-SSH2 javalib.

        ssh2_conn
        
    end
    
    methods
        
        function this = DoseMonitor(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            % this.connect();
            
        end
        
        
        function lSuccess = connect(this)
            
            %{
            cCommand = sprintf('ssh %s@%s', this.cUser, this.cTcpipHost);
            [status, cmdout] = system(cCommand); 
            lSuccess = status == 0;
            %}
            
            this.ssh2_conn = ssh2_config(this.cHost,this.cUser,this.cPassword);
            % this.executeStartScript();
            lSuccess = true;
            
            
        end
        
        % as of 2022.01 this function blocks matlab indefinitely.  Only
        % solution is to SSH in and run this on the raspberry PI machine
        % IP is shown above
        function lSuccess = executeStartScript(this)
            
            
            cCommand = sprintf('%s', this.cPathStartScript);
            
            % optional third argument to suppress output
            enablePrint = 0;
            this.ssh2_conn = ssh2_command(this.ssh2_conn, cCommand, enablePrint);
           
            lSuccess = true;
        end
        
        
        % Returns total charge (in number of electrons) when provided with the gain of the
        % current amplifier that converts amps to volts.  Assumes
        % voltage is constant over each sample domain (the signal is 
        % adequately sampled by the ADC)
        
        function [dCharge, lSuccess] = getCharge(this, dGain)
            
            [cWord, lSuccess] = this.read();
            [cTiming, cIncrement, dSamples, dCounts] = this.getValuesFromDataWord(cWord);
            
            dCountsZero = dSamples * 131072;
            dCounts = dCounts - dCountsZero;
            
            % 1 ADC count is 20V/2^18 = 76e-6 V
            % See google Drive file Dose Monitor Documentation v5
            
            dSeconds = dSamples / 100e3; % 100 kHz ADC
            dPeriodADC = 1e-5; % seconds per sample
            dVoltsSum = dCounts * 76e-6; % accumulated
            dAmpsSum = dVoltsSum * dGain;
            dCharge = dAmpsSum * dPeriodADC; % discrete integral of I(t) vs. t
            dChargeElectron = 1.60217662e-19;
            dCharge = round(dCharge / dChargeElectron); % return number of photoelectrons
                        
           
            % A quick back-of-envelope
            % Assume 150 pA of current (3V at gain of 50 pA/V)
            % Assume 2.2 seconds exposure
            % gives about 2 billion photoelectrons
            % 150e-12 * 2.2 / 1.6e-19
        end
        
        function [dCounts, lSuccess] = getCounts(this)
            [cWord, lSuccess] = this.read();
            [cTiming, cIncrement, dSamples, dCounts] = this.getValuesFromDataWord(cWord);   
            
            % The range of the ADC is -10V to +10V
            % Voltage sample of -10V is 0x00000 (0) counts
            % Voltage sample of 0 V is 0x20000 (131072)
            % Voltage sample of 10V is 0x3ffff (262143) counts
            % dSamples of these samples get summed together and that is
            % dCounts.
            % Need to subtract dSamples * 131072 from dCounts to get the 
            % corrected value.
            
            % 1 ADC count is 20V/2^18 = 76e-6 V
            % See google Drive file Dose Monitor Documentation v5
            
            dSamples;
            dCountsZero = dSamples * 131072;
            dCounts = dCounts - dCountsZero;
            dCounts;
            dVolts = dCounts * 76e-6; % accumulated
            dVoltsPerSample = dVolts / dSamples;
        end
        
        
        function [cVal, lSuccess] = read(this)
            
            cCommand = sprintf('cat %s', this.cPathData);
            % cCommand = 'pwd';
            
            %{
            [status, cVal] = system(cCommand);
            lSuccess = status == 0;
            %}
            
            enablePrint = 0;
            
            [this.ssh2_conn, result] = ssh2_command(this.ssh2_conn, cCommand, enablePrint);
            ceResponse = ssh2_command_response(this.ssh2_conn); % cell with one element for response of each command
            cVal = ceResponse{1};
            lSuccess = true;
            
            
        end
        
        function [cTiming, cIncrement, dSamples, dCounts] = getValuesFromDataWord(this, cWord)
            
            % Timing sync
            cursor = 3; % skip the 0x hex identifier
            nibbles = 3;
            cTiming = cWord(cursor: cursor+nibbles - 1);
            cursor = cursor + nibbles;

            % Increment
            nibbles = 1;
            cIncrement = cWord(cursor: cursor+nibbles - 1);
            cursor = cursor + nibbles;
            
            % Samples
            nibbles = 8;
            cSamples = cWord(cursor: cursor+nibbles - 1);
            cursor = cursor + nibbles;
            dSamples = hex2dec(cSamples);
            
            % Counts
            nibbles = 12;
            cCounts = cWord(cursor: cursor+nibbles - 1);
            cursor = cursor + nibbles;
            dCounts = hex2dec(cCounts);
             
        end
        
        
        function lSuccess = disconnect(this)
            
            %{
            [status, cmdout] = system('exit');
            lSuccess = status == 0;
            %}
            
            this.ssh2_conn = ssh2_close(this.ssh2_conn);
            lSuccess = true;

            
        end
        
         function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
        
        function msg(this, cMsg)
           fprintf('%s\n', cMsg); 
        end
        
        
        
    end
    
end

