classdef Acquisition < ws.system.AcquisitionSubsystem
    
    methods
        function self = Acquisition(parent)
            self@ws.system.AcquisitionSubsystem(parent);
        end
                
        function initializeFromMDFStructure(self, mdfStructure)
            terminalNames = mdfStructure.physicalInputChannelNames ;
            
            if ~isempty(terminalNames) ,
                channelNames = mdfStructure.inputChannelNames;

                % Deal with the device names, setting the WSM DeviceName if
                % it's not set yet.
                deviceNames = ws.utility.deviceNamesFromTerminalNames(terminalNames);
                uniqueDeviceNames=unique(deviceNames);
                if length(uniqueDeviceNames)>1 ,
                    error('ws:MoreThanOneDeviceName', ...
                          'WaveSurfer only supports a single NI card at present.');                      
                end
                deviceName = uniqueDeviceNames{1} ;                
                if isempty(self.Parent.DeviceName) ,
                    self.Parent.DeviceName = deviceName ;
                end

                % Get the channel IDs
                terminalIDs = ws.utility.terminalIDsFromTerminalNames(terminalNames);
                
                % Figure out which are analog and which are digital
                channelTypes = ws.utility.channelTypesFromTerminalNames(terminalNames);
                isAnalog = strcmp(channelTypes,'ai');
                isDigital = ~isAnalog;

                % Sort the channel names, etc
                %analogDeviceNames = deviceNames(isAnalog) ;
                %digitalDeviceNames = deviceNames(isDigital) ;
                analogTerminalIDs = terminalIDs(isAnalog) ;
                digitalTerminalIDs = terminalIDs(isDigital) ;            
                analogChannelNames = channelNames(isAnalog) ;
                digitalChannelNames = channelNames(isDigital) ;

                % add the analog channels
                nAnalogChannels = length(analogChannelNames);
                for i = 1:nAnalogChannels ,
                    self.addAnalogChannel() ;
                    indexOfChannelInSelf = self.NAnalogChannels ;
                    self.setSingleAnalogChannelName(indexOfChannelInSelf, analogChannelNames(i)) ;                    
                    self.setSingleAnalogTerminalID(indexOfChannelInSelf, analogTerminalIDs(i)) ;
                end
                
                % add the digital channels
                nDigitalChannels = length(digitalChannelNames);
                for i = 1:nDigitalChannels ,
                    self.addDigitalChannel() ;
                    indexOfChannelInSelf = self.NDigitalChannels ;
                    self.setSingleDigitalChannelName(indexOfChannelInSelf, digitalChannelNames(i)) ;
                    self.Parent.setSingleDIChannelTerminalID(indexOfChannelInSelf, digitalTerminalIDs(i)) ;
                end                
            end
        end  % function
        
%         function settings = packageCoreSettings(self)
%             settings=struct() ;
%             for i=1:length(self.CoreFieldNames_)
%                 fieldName = self.CoreFieldNames_{i} ;
%                 settings.(fieldName) = self.(fieldName) ;
%             end
%         end        
    end  % methods block    
    
    
    methods
        function startingRun(self)
            %fprintf('Acquisition::startingRun()\n');
            %errors = [];
            %abort = false;
            
%             if isempty(self.TriggerScheme) ,
%                 error('wavesurfer:acquisitionsystem:invalidtrigger', ...
%                       'The acquisition trigger scheme can not be empty when the system is enabled.');
%             end
%             
%             if isempty(self.TriggerScheme.Target) ,
%                 error('wavesurfer:acquisitionsystem:invalidtrigger', ...
%                       'The acquisition trigger scheme target can not be empty when the system is enabled.');
%             end
            
            wavesurferModel = self.Parent ;
            
%             % Make the NI daq task, if don't have it already
%             self.acquireHardwareResources_();

%             % Set up the task triggering
%             self.AnalogInputTask_.TriggerPFIID = self.TriggerScheme.Target.PFIID;
%             self.AnalogInputTask_.TriggerEdge = self.TriggerScheme.Target.Edge;
%             self.DigitalInputTask_.TriggerPFIID = self.TriggerScheme.Target.PFIID;
%             self.DigitalInputTask_.TriggerEdge = self.TriggerScheme.Target.Edge;
%             
%             % Set for finite vs. continous sampling
%             if wavesurferModel.AreSweepsContinuous ,
%                 self.AnalogInputTask_.ClockTiming = 'DAQmx_Val_ContSamps';
%                 self.DigitalInputTask_.ClockTiming = 'DAQmx_Val_ContSamps';
%             else
%                 self.AnalogInputTask_.ClockTiming = 'DAQmx_Val_FiniteSamps';
%                 self.AnalogInputTask_.AcquisitionDuration = self.Duration ;
%                 self.DigitalInputTask_.ClockTiming = 'DAQmx_Val_FiniteSamps';
%                 self.DigitalInputTask_.AcquisitionDuration = self.Duration ;
%             end

            % Check that there's at least one active input channel
            NActiveAnalogChannels = sum(self.IsAnalogChannelActive);
            NActiveDigitalChannels = sum(self.IsDigitalChannelActive);
            NActiveInputChannels = NActiveAnalogChannels + NActiveDigitalChannels ;
            if NActiveInputChannels==0 ,
                error('wavesurfer:NoActiveInputChannels' , ...
                      'There must be at least one active input channel to perform a run');
            end

            % Dimension the cache that will hold acquired data in main memory
            if self.NDigitalChannels<=8
                dataType = 'uint8';
            elseif self.NDigitalChannels<=16
                dataType = 'uint16';
            else %self.NDigitalChannels<=32
                dataType = 'uint32';
            end
            if wavesurferModel.AreSweepsContinuous ,
                nScans = round(self.DataCacheDurationWhenContinuous_ * self.SampleRate) ;
                self.RawAnalogDataCache_ = zeros(nScans,NActiveAnalogChannels,'int16');
                self.RawDigitalDataCache_ = zeros(nScans,min(1,NActiveDigitalChannels),dataType);
            elseif wavesurferModel.AreSweepsFiniteDuration ,
                self.RawAnalogDataCache_ = zeros(self.ExpectedScanCount,NActiveAnalogChannels,'int16');
                self.RawDigitalDataCache_ = zeros(self.ExpectedScanCount,min(1,NActiveDigitalChannels),dataType);
            else
                % Shouldn't ever happen
                self.RawAnalogDataCache_ = [];                
                self.RawDigitalDataCache_ = [];                
            end
            
%             % Arm the AI task
%             self.AnalogInputTask_.arm();
%             self.DigitalInputTask_.arm();
        end  % function
        
        function wasSet = setSingleDigitalTerminalID(self, i, newValue)
            % This should only be called from the parent
            if 1<=i && i<=self.NDigitalChannels && isnumeric(newValue) && isscalar(newValue) && isfinite(newValue) ,
                newValueAsDouble = double(newValue) ;
                if newValueAsDouble>=0 && newValueAsDouble==round(newValueAsDouble) ,
                    self.DigitalTerminalIDs_(i) = newValueAsDouble ;
                    wasSet = true ;
                else
                    wasSet = false ;
                end
            else
                wasSet = false ;
            end                
            %self.Parent.didSetDigitalInputTerminalID();
        end
    end  % public methods block

    methods (Access=protected)
        function value = getAnalogChannelScales_(self)
            wavesurferModel=self.Parent;
            if isempty(wavesurferModel) ,
                ephys=[];
            else
                ephys=wavesurferModel.Ephys;
            end
            if isempty(ephys) ,
                electrodeManager=[];
            else
                electrodeManager=ephys.ElectrodeManager;
            end
            if isempty(electrodeManager) ,
                value=self.AnalogChannelScales_;
            else
                analogChannelNames=self.AnalogChannelNames;
                [channelScalesFromElectrodes, ...
                 isChannelScaleEnslaved] = ...
                    electrodeManager.getMonitorScalingsByName(analogChannelNames);
                value=ws.utility.fif(isChannelScaleEnslaved,channelScalesFromElectrodes,self.AnalogChannelScales_);
            end
        end
    end  % methods block    
    
    
end  % classdef
