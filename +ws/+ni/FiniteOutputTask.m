classdef FiniteOutputTask < handle
    properties (Dependent = true, SetAccess = immutable)
        IsAnalog
        IsDigital
        TaskName
        PhysicalChannelNames
        ChannelNames
        IsArmed  % generally shouldn't set props, etc when armed (but setting ChannelData is actually OK)
        OutputDuration
    end
    
    properties (Dependent = true)
        SampleRate      % Hz
        TriggerPFIID
        TriggerEdge
        ChannelData
    end
    
    properties (Access = protected, Transient = true)
        DabsDaqTask_ = [];
    end
    
    properties (Access = protected)
        IsAnalog_
        SampleRate_ = 20000
        TriggerPFIID_ = []
        TriggerEdge_ = []
        IsArmed_ = false
        PhysicalChannelNames_ = cell(1,0)
        ChannelNames_ = cell(1,0)
        ChannelData_
    end
    
    events
        OutputComplete
    end

    methods
        function self = FiniteOutputTask(taskType, taskName, physicalChannelNames, channelNames)
            nChannels=length(physicalChannelNames);
                                    
            % Determine the task type, digital or analog
            if isequal(taskType,'analog') ,
                self.IsAnalog_ = true ;
            elseif isequal(taskType,'digital') ,
                self.IsAnalog_ = false ;
            else
                error('Illegal output task type');
            end                
            
            % Create the task, channels
            if nChannels==0 ,
                self.DabsDaqTask_ = [];
            else
                self.DabsDaqTask_ = ws.dabs.ni.daqmx.Task(taskName);
            end            
            
            % Store this stuff
            self.PhysicalChannelNames_ = physicalChannelNames ;
            self.ChannelNames_ = channelNames ;
            
            % Create the channels, set the timing mode (has to be done
            % after adding channels)
            if nChannels>0 ,
                for i=1:nChannels ,
                    physicalChannelName = physicalChannelNames{i} ;
                    if self.IsAnalog ,
                        channelName = channelNames{i} ;
                        deviceName = ws.utility.deviceNameFromPhysicalChannelName(physicalChannelName);
                        channelID = ws.utility.channelIDFromPhysicalChannelName(physicalChannelName);
                        self.DabsDaqTask_.createAOVoltageChan(deviceName, channelID, channelName);
                    else
                        physicalChannelName = physicalChannelNames{i} ;
                        deviceName = ws.utility.deviceNameFromPhysicalChannelName(physicalChannelName);
                        restOfName = ws.utility.chopDeviceNameFromPhysicalChannelName(physicalChannelName);
                        self.DabsDaqTask_.createDOChan(deviceName, restOfName);
                    end
                end                
                self.DabsDaqTask_.cfgSampClkTiming(self.SampleRate, 'DAQmx_Val_FiniteSamps');
            end
            
        end  % function
        
        function delete(self)
            if ~isempty(self.DabsDaqTask_) && self.DabsDaqTask_.isvalid() ,
                delete(self.DabsDaqTask_);  % have to explicitly delete, b/c ws.dabs.ni.daqmx.System has refs to, I guess
            end
            self.DabsDaqTask_=[];
        end  % function
        
        function start(self)
%             if isa(self,'ws.ni.FiniteAnalogOutputTask') ,
%                 %fprintf('About to start FiniteAnalogOutputTask.\n');
%                 %self
%                 %dbstack
%             end               
            if self.IsArmed_ ,
                if ~isempty(self.DabsDaqTask_) ,
                    self.DabsDaqTask_.start();
                end
            end
        end  % function
        
        function abort(self)
%             if isa(self,'ws.ni.AnalogInputTask') ,
%                 fprintf('AnalogInputTask::abort()\n');
%             end
%             if isa(self,'ws.ni.FiniteAnalogOutputTask') ,
%                 fprintf('FiniteAnalogOutputTask::abort()\n');
%             end
            if ~isempty(self.DabsDaqTask_)
                self.DabsDaqTask_.abort();
            end
        end  % function
        
        function stop(self)
%             if isa(self,'ws.ni.AnalogInputTask') ,
%                 fprintf('AnalogInputTask::stop()\n');
%             end
%             if isa(self,'ws.ni.FiniteAnalogOutputTask') ,
%                 fprintf('FiniteAnalogOutputTask::stop()\n');
%             end
            if ~isempty(self.DabsDaqTask_) && ~self.DabsDaqTask_.isTaskDoneQuiet()
                self.DabsDaqTask_.stop();
            end
        end  % function
        
        function value = get.IsArmed(self)
            value = self.IsArmed_;
        end  % function
        
        function value = get.IsAnalog(self)
            value = self.IsAnalog_;
        end  % function
        
        function value = get.IsDigital(self)
            value = ~self.IsAnalog_;
        end  % function
        
        function clearChannelData(self)
            nChannels=length(self.ChannelNames);
            if self.IsAnalog ,
                self.ChannelData = zeros(0,nChannels);  % N.B.: Want to use pubic setter, so output buffer gets sync'ed
            else
                self.ChannelData = false(0,nChannels);  % N.B.: Want to use pubic setter, so output buffer gets sync'ed
            end                
        end  % function
        
        function value = get.ChannelData(self)
            value = self.ChannelData_;
        end  % function
        
        function set.ChannelData(self, value)
            nChannels=length(self.ChannelNames);
            if self.IsAnalog ,
                requiredType = 'double' ;
            else
                requiredType = 'logical' ;
            end
            if isa(value,requiredType) && ismatrix(value) && (size(value,2)==nChannels) ,
                self.ChannelData_ = value;
                self.syncOuputBufferToChannelData_();
            else
                error('most:Model:invalidPropVal', ...
                      'ChannelData must be an NxR matrix, R the number of channels, of the appropriate type.');
            end
        end  % function        
        
        function value = get.OutputDuration(self)
            value = size(self.ChannelData_,1) * self.SampleRate;
        end  % function        
        
        function debug(self) %#ok<MANU>
            keyboard
        end  % function        
    end  % methods
    
    methods                
        function out = get.PhysicalChannelNames(self)
            out = self.PhysicalChannelNames_ ;
        end  % function

        function out = get.ChannelNames(self)
            out = self.ChannelNames_ ;
        end  % function
                    
        function value = get.SampleRate(self)
            value = self.SampleRate_;
        end  % function
        
        function set.SampleRate(self, newValue)
            if ~( isnumeric(newValue) && isscalar(newValue) && newValue==round(newValue) && newValue>0 )  ,
                error('most:Model:invalidPropVal', ...
                      'SampleRate must be a positive integer');       
            end            
                        
            if isempty(self.DabsDaqTask_) ,
                self.SampleRate_ = newValue;
            else                
                nScansInBuffer = self.DabsDaqTask_.get('bufOutputBufSize');
                if nScansInBuffer > 0 ,                
                    originalSampleRate = self.DabsDaqTask_.sampClkRate;
                    self.DabsDaqTask_.sampClkRate = newValue;
                    self.SampleRate_ = newValue;
                    try
                        self.DabsDaqTask_.control('DAQmx_Val_Task_Verify');
                    catch me
                        self.DabsDaqTask_.sampClkRate = originalSampleRate;
                        self.SampleRate_ = originalSampleRate;
                        error('Invalid sample rate value');
                    end
                else
                    self.SampleRate_ = newValue;
                end
            end
        end  % function
        
        function out = get.TaskName(self)
            if isempty(self.DabsDaqTask_) ,
                out = '';
            else
                out = self.DabsDaqTask_.taskName;
            end
        end  % function
        
        function set.TriggerPFIID(self, newValue)
            if isempty(newValue) ,
                self.TriggerPFIID_ = [];
            elseif isnumeric(newValue) && isscalar(newValue) && (newValue==round(newValue)) && (newValue>=0) ,
                self.TriggerPFIID_ = double(newValue);
            else
                error('most:Model:invalidPropVal', ...
                      'TriggerPFIID must be empty or a scalar natural number');       
            end            
        end  % function
        
        function value = get.TriggerPFIID(self)
            value = self.TriggerPFIID_ ;
        end  % function                

        function set.TriggerEdge(self, newValue)
            if isempty(newValue) ,
                self.TriggerEdge_ = [];
            elseif isa(newValue,'ws.ni.TriggerEdge') && isscalar(newValue) ,
                self.TriggerEdge_ = newValue;
            else
                error('most:Model:invalidPropVal', ...
                      'TriggerEdge must be empty or a scalar ws.ni.TriggerEdge');       
            end            
        end  % function
        
        function value = get.TriggerEdge(self)
            value = self.TriggerEdge_ ;
        end  % function                
                
        function arm(self)
            % called before the first call to start()            
%             %fprintf('FiniteAnalogOutputTask::setup()\n');
            if self.IsArmed_ ,
                return
            end
            
            % Configure self.DabsDaqTask_ 
            if isempty(self.DabsDaqTask_) ,
                % do nothing
            else
                % Set up callbacks
                self.DabsDaqTask_.doneEventCallbacks = {@self.taskDone_};            

                % Set up triggering
                if ~isempty(self.TriggerPFIID)
                    self.DabsDaqTask_.cfgDigEdgeStartTrig(sprintf('PFI%d', self.TriggerPFIID), self.TriggerEdge.daqmxName());
                else
                    self.DabsDaqTask_.disableStartTrig();
                end
            end
            
            % Note that we are now armed
            self.IsArmed_ = true;
        end  % function

        function disarm(self)
            if self.IsArmed_ ,            
                if isempty(self.DabsDaqTask_) ,
                    % do nothing
                else
                    % Unregister callbacks
                    self.DabsDaqTask_.doneEventCallbacks = {};

                    % Unreserve resources
                    self.DabsDaqTask_.control('DAQmx_Val_Task_Unreserve');
                end
                
                % Note that we are now disarmed
                self.IsArmed_ = false;
            end
        end  % function                
    end  % public methods
    
    methods (Access = protected)        
        function taskDone_(self, ~, ~)
            % For a successful capture, this class is responsible for stopping the task when
            % it is done.  For external clients to interrupt a running task, use the abort()
            % method on the Output object.
            self.DabsDaqTask_.stop();
            
            % Fire the event before unregistering the callback functions.  At the end of a
            % script the DAQmx callbacks may be the only references preventing the object
            % from deleting before the events are sent/complete.
            self.notify('OutputComplete');
        end  % function        
    end  % protected methods block
    
    methods (Access = protected)
        function syncOuputBufferToChannelData_(self)
            % Get the channel data into a local
            channelData=self.ChannelData;
            
            % The outputData is the channelData, unless the channelData is
            % very short, in which case the outputData is just long
            % enough, and all zeros
            nScansInChannelData = size(channelData,1) ;            
            if nScansInChannelData<2 ,
                nChannels = length(self.ChannelNames) ;
                if self.IsAnalog ,
                    outputData=zeros(2,nChannels);
                else
                    outputData=false(2,nChannels);
                end
            else
                outputData = self.ChannelData ;
            end
            
            % Actually set up the task, if present
            if isempty(self.DabsDaqTask_) ,
                % do nothing
            else            
                % Resize the output buffer to the number of scans in outputData
                nScansInOutputData=size(outputData,1);
                nScansInBuffer = self.DabsDaqTask_.get('bufOutputBufSize');
                if nScansInBuffer ~= nScansInOutputData ,
                    self.DabsDaqTask_.cfgOutputBuffer(nScansInOutputData);
                end

                % Configure the the number of scans in the finite-duration output
                self.DabsDaqTask_.cfgSampClkTiming(self.SampleRate, 'DAQmx_Val_FiniteSamps', nScansInOutputData);

                % Write the data to the output buffer
                if self.IsAnalog ,
                    outputData(end,:)=0;  % don't want to end on nonzero value
                    self.DabsDaqTask_.reset('writeRelativeTo');
                    self.DabsDaqTask_.reset('writeOffset');
                    self.DabsDaqTask_.writeAnalogData(outputData);
                else
                    packedOutputData = self.packDigitalData_(outputData);  % uint32, nScansInOutputData x 1
                    packedOutputData(end)=0;  % don't want to end on nonzero value
                    self.DabsDaqTask_.reset('writeRelativeTo');
                    self.DabsDaqTask_.reset('writeOffset');
                    self.DabsDaqTask_.writeDigitalData(packedOutputData);
                end
            end
        end  % function

        function packedOutputData = packDigitalData_(self,outputData)
            % Only used for digital data.
            [nScans,nChannels] = size(outputData);
            packedOutputData = zeros(nScans,1,'uint32');
            channelIDs = ws.utility.channelIDsFromPhysicalChannelNames(self.PhysicalChannelNames);
            for j=1:nChannels ,
                channelID = channelIDs(j);
                thisChannelData = uint32(outputData(:,j));
                thisChannelDataShifted = bitshift(thisChannelData,channelID) ;
                packedOutputData = bitor(packedOutputData,thisChannelDataShifted);
            end
        end  % function
    end  % Static methods
    
end  % classdef