classdef PezController < handle
    
    properties (Access=private)
        Model_
        Figure_
        TrialSequenceModeLabel_
        TrialSequenceModePopupMenu_
        
        BasePosition1XLabelledEdit_
        BasePosition1YLabelledEdit_
        BasePosition1ZLabelledEdit_        
        ToneFrequency1LabelledEdit_
        DeliverPosition1XLabelledEdit_
        DeliverPosition1YLabelledEdit_
        DeliverPosition1ZLabelledEdit_        
        DispenseChannelPosition1LabelledEdit_
        
        BasePosition2XLabelledEdit_
        BasePosition2YLabelledEdit_
        BasePosition2ZLabelledEdit_        
        ToneFrequency2LabelledEdit_
        DeliverPosition2XLabelledEdit_
        DeliverPosition2YLabelledEdit_
        DeliverPosition2ZLabelledEdit_        
        DispenseChannelPosition2LabelledEdit_
        
        ToneDurationLabelledEdit_
        ToneDelayLabelledEdit_
        DispenseDelayLabelledEdit_
        ReturnDelayLabelledEdit_
    end

    methods
        function self = PezController(model)
            self.Model_ = model ;
            fig = figure('Name', 'Pez', ...
                         'MenuBar', 'none', ...
                         'IntegerHandle', 'off', ...
                         'HandleVisibility', 'off') ;
            self.Figure_ = fig ;
            
            self.TrialSequenceModeLabel_ = ...
                ws.uicontrol('Parent', fig, ...
                             'Style', 'text', ...
                             'String', 'Mode:') ;
            self.TrialSequenceModePopupMenu_ = ...
                ws.uipopupmenu(...
                    'Parent', fig, ...
                    'Tag', 'TrialSequenceMode', ...
                    'Callback', @(source,event)(self.controlActuated(source, event)), ...
                    'String',{'<borkenness>'}, ...
                    'Value',1) ;
            
            self.BasePosition1XLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'BasePosition1X', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Base X:', ...
                                         'UnitsString', 'mm') ;
            self.BasePosition1YLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'BasePosition1Y', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Base Y:', ...
                                         'UnitsString', 'mm') ;
            self.BasePosition1ZLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'BasePosition1Z', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Base Z:', ...
                                         'UnitsString', 'mm') ;
            self.ToneFrequency1LabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'ToneFrequency1', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Tone Frequency:', ...
                                         'UnitsString', 'Hz') ;
            self.DeliverPosition1XLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DeliverPosition1X', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Delivery X:', ...
                                         'UnitsString', 'mm') ;
            self.DeliverPosition1YLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DeliverPosition1Y', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Delivery Y:', ...
                                         'UnitsString', 'mm') ;
            self.DeliverPosition1ZLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DeliverPosition1Z', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Delivery Z:', ...
                                         'UnitsString', 'mm') ;
            self.DispenseChannelPosition1LabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DispenseChannelPosition1', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 1 Dispense X Offset:', ...
                                         'UnitsString', 'mm') ;
                                     
            self.BasePosition2XLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'BasePosition2X', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Base X:', ...
                                         'UnitsString', 'mm') ;
            self.BasePosition2YLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'BasePosition2Y', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Base Y:', ...
                                         'UnitsString', 'mm') ;
            self.BasePosition2ZLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'BasePosition2Z', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Base Z:', ...
                                         'UnitsString', 'mm') ;
            self.ToneFrequency2LabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'ToneFrequency2', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Tone Frequency:', ...
                                         'UnitsString', 'Hz') ;
            self.DeliverPosition2XLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DeliverPosition2X', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Delivery X:', ...
                                         'UnitsString', 'mm') ;
            self.DeliverPosition2YLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DeliverPosition2Y', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Delivery Y:', ...
                                         'UnitsString', 'mm') ;
            self.DeliverPosition2ZLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DeliverPosition2Z', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Delivery Z:', ...
                                         'UnitsString', 'mm') ;
            self.DispenseChannelPosition2LabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DispenseChannelPosition2', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Condition 2 Dispense X Offset:', ...
                                         'UnitsString', 'mm') ;
                                     
            self.ToneDurationLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'ToneDuration', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Tone Duration:', ...
                                         'UnitsString', 's') ;
            self.ToneDelayLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'ToneDelay', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Tone Delay:', ...
                                         'UnitsString', 's') ;
            self.DispenseDelayLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'DispenseDelay', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Dispense Delay:', ...
                                         'UnitsString', 's') ;
            self.ReturnDelayLabelledEdit_ = ...
                ws.examples.LabelledEdit('Parent', fig, ...
                                         'Tag', 'ReturnDelay', ...
                                         'Callback', @(source,event)(self.controlActuated(source, event)), ...
                                         'HorizontalAlignment', 'right', ...
                                         'LabelString', 'Return Delay:', ...
                                         'UnitsString', 's') ;
            
            self.layout_() ;
            self.update_() ;
        end
        
        function delete(self)
            if ~isempty(self.Figure_) && ishandle(self.Figure_) ,
                delete(self.Figure_) ;
            end
        end

        function controlActuated(self, source, event)  %#ok<INUSD>
            if source==self.TrialSequenceModePopupMenu_ ,
                newValueAsString = ws.getPopupMenuSelection(source, self.Model_.TrialSequenceModeOptions) ;
                self.Model_.TrialSequenceMode = newValueAsString ;
            else
                % Must be an edit
                tag = source.Tag ;
                propertyName = tag ;
                newValueAsString = source.String ;
                newValue = str2double(newValueAsString) ;
                if isfinite(newValue) ,
                    self.Model_.(propertyName) = newValue ;
                end
            end
            self.update_() ;
        end
        
    end  % public methods block    
    
    methods (Access=private)
        function layout_(self)
            figureWidth = 300 ;
            figureHeight = 710 ;
            
            defaultYSpacing = 30 ;
            xBaseline = 180 ;
            popupMenuWidth = 80 ;
            editWidth = 60 ;
            intergroupExtraYSpace = 20 ;
            belowModeExtraYSpace = 10 ;
            
            ws.resizeLeavingUpperLeftFixedBang(self.Figure_, [figureWidth figureHeight]) ;
            
            yOffset = figureHeight - 40 ;
            self.TrialSequenceModePopupMenu_.Position(1:2) = [xBaseline yOffset] ;
            ws.positionPopupmenuAndLabelBang(self.TrialSequenceModeLabel_, ...
                                             self.TrialSequenceModePopupMenu_, ...
                                             xBaseline, ...
                                             yOffset, ...
                                             popupMenuWidth) ;
            
                                         
                                         
            yOffset = yOffset - defaultYSpacing - belowModeExtraYSpace ;
            self.BasePosition1XLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.BasePosition1XLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.BasePosition1YLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.BasePosition1YLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.BasePosition1ZLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.BasePosition1ZLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.ToneFrequency1LabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.ToneFrequency1LabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DeliverPosition1XLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DeliverPosition1XLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DeliverPosition1YLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DeliverPosition1YLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DeliverPosition1ZLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DeliverPosition1ZLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DispenseChannelPosition1LabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DispenseChannelPosition1LabelledEdit_.Position(3)   = editWidth ;
            

            
            yOffset = yOffset - defaultYSpacing - intergroupExtraYSpace;
            self.BasePosition2XLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.BasePosition2XLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.BasePosition2YLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.BasePosition2YLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.BasePosition2ZLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.BasePosition2ZLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.ToneFrequency2LabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.ToneFrequency2LabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DeliverPosition2XLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DeliverPosition2XLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DeliverPosition2YLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DeliverPosition2YLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DeliverPosition2ZLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DeliverPosition2ZLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DispenseChannelPosition2LabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DispenseChannelPosition2LabelledEdit_.Position(3)   = editWidth ;

            
            
            yOffset = yOffset - defaultYSpacing - intergroupExtraYSpace;
            self.ToneDurationLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.ToneDurationLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.ToneDelayLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.ToneDelayLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.DispenseDelayLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.DispenseDelayLabelledEdit_.Position(3)   = editWidth ;
            
            yOffset = yOffset - defaultYSpacing ;
            self.ReturnDelayLabelledEdit_.Position(1:2) = [xBaseline yOffset] ;
            self.ReturnDelayLabelledEdit_.Position(3)   = editWidth ;
        end
        
        function update_(self)
            ws.setPopupMenuItemsAndSelectionBang(self.TrialSequenceModePopupMenu_, ...
                                                 self.Model_.TrialSequenceModeOptions, ...
                                                 self.Model_.TrialSequenceMode) ;
            
            self.BasePosition1XLabelledEdit_.EditString = sprintf('%g', self.Model_.BasePosition1X) ;            
            self.BasePosition1YLabelledEdit_.EditString = sprintf('%g', self.Model_.BasePosition1Y) ;            
            self.BasePosition1ZLabelledEdit_.EditString = sprintf('%g', self.Model_.BasePosition1Z) ;            
            self.ToneFrequency1LabelledEdit_.EditString = sprintf('%g', self.Model_.ToneFrequency1) ;                        
            self.DeliverPosition1XLabelledEdit_.EditString = sprintf('%g', self.Model_.DeliverPosition1X) ;            
            self.DeliverPosition1YLabelledEdit_.EditString = sprintf('%g', self.Model_.DeliverPosition1Y) ;            
            self.DeliverPosition1ZLabelledEdit_.EditString = sprintf('%g', self.Model_.DeliverPosition1Z) ;            
            self.DispenseChannelPosition1LabelledEdit_.EditString = sprintf('%g', self.Model_.DispenseChannelPosition1) ;                        
            
            self.BasePosition2XLabelledEdit_.EditString = sprintf('%g', self.Model_.BasePosition2X) ;            
            self.BasePosition2YLabelledEdit_.EditString = sprintf('%g', self.Model_.BasePosition2Y) ;            
            self.BasePosition2ZLabelledEdit_.EditString = sprintf('%g', self.Model_.BasePosition2Z) ;            
            self.ToneFrequency2LabelledEdit_.EditString = sprintf('%g', self.Model_.ToneFrequency2) ;                        
            self.DeliverPosition2XLabelledEdit_.EditString = sprintf('%g', self.Model_.DeliverPosition2X) ;            
            self.DeliverPosition2YLabelledEdit_.EditString = sprintf('%g', self.Model_.DeliverPosition2Y) ;            
            self.DeliverPosition2ZLabelledEdit_.EditString = sprintf('%g', self.Model_.DeliverPosition2Z) ;            
            self.DispenseChannelPosition2LabelledEdit_.EditString = sprintf('%g', self.Model_.DispenseChannelPosition2) ;

            self.ToneDurationLabelledEdit_.EditString = sprintf('%g', self.Model_.ToneDuration) ;
            self.ToneDelayLabelledEdit_.EditString = sprintf('%g', self.Model_.ToneDelay) ;
            self.DispenseDelayLabelledEdit_.EditString = sprintf('%g', self.Model_.DispenseDelay) ;
            self.ReturnDelayLabelledEdit_.EditString = sprintf('%g', self.Model_.ReturnDelay) ;            
        end        
    end  % private methods block    
    
end  % classdef
