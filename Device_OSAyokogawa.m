classdef Device_OSAyokogawa
    properties (Constant)
        PORT = 10001;
        PASSWORD_RESPONSE = "ready"
        TRACES = 'ABCDEFG';
        NAMES_ANALYSIS_NF = {'center_wl','input_lvl',...
            'output_lvl','ase_lvl','resoln','gain','nf'}%"ch_num"(first)'s skipped
    end
    properties (Constant) % Requests
        % if name ends with "_X" it requires number and maybe units
        CONNECT_USERNAME= 'open "admin"'
        PASSWORD = 'admin'
        REQUESTS_MODE = 'CFORM1' % Установка формата команд
        CALC_MODE_AUTO = ':CALCULATE:AUTO ON' % Установка авто измерения в вкл % 7-52
        SWTHRESH = ':CALCULATE:PARAMETER:SWTHRESH:TH 3.00DB' % Расчет спектральной ширины по уровню 3 db
        LMARKER_AOFF = ':CALCulate:LMARker:AOFF' % p.7-52 %% Очищение всех маркеров
        WAVELENGTH_START_X = ':SENSe:WAVelength:STARt '
        WAVELENGTH_STOP_X = ':SENSe:WAVelength:STOP '
        SENSE_MODE_X = ':SENSe:SENSe '
        SENSE_BANDWIDTH_X = ':SENSe:BANDwidth ' %obj.resolution 'NM' %SENSE_BANDWIDTH_X IMAQ6370C-17EN p.7-85
        REFERENSE_LEVEL_X = ':DISPlay:TRACe:Y1:RLEVel ' %obj.referenceLevel 'dbm' %REFERENSE_LEVEL_X 7-75
        LEVEL_SCALE_X = ':DISPlay:TRACe:Y1:PDIVision ' %obj.levelScale 'DB' %LEVEL_SCALE
        TRACE_ACTIVE_X = ':TRACe:ACTive TR' %strcat(,trace) %TRACE_ACTIVE_X
        TRACE_VISIBLE_X = ':TRACe:STATe:TR'%strcat( ,trace,' 1') %TRACE_VISIBLE_X
        TRACE_MODE_X = ':TRACE:ATTRIBUTE:TR' %all_traces(i) write_or_fix]; %TRACE_MODE_X
        WRITE_WAVEFORM_MODE = ':init:smode 1'
        WRITE_WAVEFORM_START = ':init'
        WRITE_WAVEFORM_STATUS = ':stat:oper:even?'
        WRITE_WAVEFORM_SAVE = ':mmem:stor:trac TR' %obj.waveformTrace ',csv,"test",int'];
        SAVE_OSA_PARAMETERS = ',csv,"test",int'
        SAVE_PC = ':mmem:data? "test.csv",int'
        ANALYSIS_MODE_NF = ':CALCulate:CATegory NF'
        ANALYSIS_MODE_POWER = ':CALCulate:CATegory POWer' %(7-49 manual)
        ANALYSIS_START = ':calc' %???????????? % ); %ANALYSIS_START
        ANALYSIS_READ = ':calc:data?'
        OFFSET_POWER = ':CALCulate:PARameter:POWer:OFFset '
        OFFSET_NFIN = ':CALCulate:PARameter:NF:IOFFset '
        OFFSET_NFOUT = ':CALCulate:PARameter:NF:OOFFset '
        % manual 7-32
            % ":PARameter:NF:IOFFset <NRf>[DB]"  % 7-61 manual
            % ":PARameter:NF:OOFFset <NRf>[DB]"  % 7-62 manual
            % ":PARameter:POWer:OFFSet <NRf>[DB]"  % 7-64 manual
            % <NRf>[DB] = 10.00
    end
    properties
        ipAddress
        timeOut
        isReady
        virtualObject
        referenceTrace
        waveformTrace
        folder
    end
    properties
        startWavelength
        stopWavelength
        senseMode
        resolution
        levelScale
        referenceLevel
    end
    properties
        lastReadWaveform
        lastReadWaveformPath
        lastReadAnalysisEDFANF
    end
    methods
        function obj = Device_OSAyokogawa(appStruct)
            % Constructor of class
            obj.folder = appStruct.folder;
            obj.ipAddress = appStruct.IPaddress;
            obj.timeOut = appStruct.Timeout;
            obj.referenceTrace = appStruct.Referencetrace;
            obj.waveformTrace = appStruct.Waveformtrace;
            try
                obj = connect(obj);
                obj = startRequests(obj);
            catch
                error
            end
        end
        function obj = applySettings(obj,appStructSettings)
            if appStructSettings.startWavelengthLogic
                obj.startWavelength = appStructSettings.startWavelengthValue;
                request = [obj.WAVELENGTH_START_X obj.startWavelength 'NM'];
                writeline(obj.virtualObject, request);
            end
            if appStructSettings.stopWavelengthLogic
                obj.stopWavelength = appStructSettings.stopWavelengthValue;
                request = [obj.WAVELENGTH_STOP_X obj.stopWavelength 'NM'];
                writeline(obj.virtualObject, request);
            end
            if appStructSettings.senseModeLogic
                obj.senseMode = appStructSettings.senseModeValue;
                request = [obj.SENSE_MODE_X obj.senseMode];
                writeline(obj.virtualObject, request);
            end
            if appStructSettings.senseBandwidthLogic
                obj.resolution = appStructSettings.senseBandwidthValue;
                request = [obj.SENSE_BANDWIDTH_X obj.resolution 'NM'];
                writeline(obj.virtualObject, request);
            end
            if appStructSettings.referenceLevelLogic
                obj.referenceLevel = appStructSettings.referenceLevelValue;
                request = [obj.REFERENSE_LEVEL_X obj.referenceLevel 'DBM'];
                writeline(obj.virtualObject, request);
            end
            if appStructSettings.levelScaleLogic
                obj.levelScale = appStructSettings.levelScaleValue;
                request = [obj.LEVEL_SCALE_X obj.levelScale 'DB'];
                writeline(obj.virtualObject, request);
            end
        end
        function applyOffsetSettings(obj,offsetValue,type)
            % offsetValue = '' (str)
            % type = 'power','in','out'
            if type == "power"
                request = obj.OFFSET_POWER;
            elseif type == "in"
                request = obj.OFFSET_NFIN;
            elseif type == "out"
                request = obj.OFFSET_NFOUT;
            end
            writeline(obj.virtualObject,[request offsetValue]);
        end
        function writeWaveform(obj,trace)
            writeline(obj.virtualObject,[obj.TRACE_ACTIVE_X,trace]);
            writeline(obj.virtualObject,[obj.TRACE_VISIBLE_X,trace,' 1']);
            logicTraces = trace == obj.TRACES; %puts 1 at selected trace place, 0 at others
            for i = 1:length(logicTraces)
                if logicTraces(i)
                    mode = ' WRITE';
                else
                    mode = ' FIX';
                end
                writeline(obj.virtualObject,[obj.TRACE_MODE_X,obj.TRACES(i),mode]);
            end
            writeline(obj.virtualObject, obj.WRITE_WAVEFORM_MODE);
            writeline(obj.virtualObject, obj.WRITE_WAVEFORM_START);
            status = 0;
            while ~status
                writeline(obj.virtualObject, obj.WRITE_WAVEFORM_STATUS);
                status = readline(obj.virtualObject);
                status = str2double(status);
            end
            writeline(obj.virtualObject,[obj.TRACE_MODE_X,trace,' FIX']);
        end
        function obj = readWaveform(obj,trace)
            request = [obj.WRITE_WAVEFORM_SAVE,trace,obj.SAVE_OSA_PARAMETERS];
            writeline(obj.virtualObject, request);
            flush(obj.virtualObject);
            writeline(obj.virtualObject,obj.SAVE_PC);
            firstDataLine = readline(obj.virtualObject);
            % readline() returns in firstDataLine
            % string "#612246870BCSV  "
            % which has "#" as first char,
            % number n as second char ("6" in example),
            % next n digits represent
            % number of information bytes
            % (in ex., 122468 bytes)
            firstDataLine = char(firstDataLine);
            if firstDataLine(1) ~= "#"
                disp('ERROR: wrong response!')
            end
            digitsNumber = str2double(firstDataLine(2));
            bytesNumber = str2double(firstDataLine(3:3 + digitsNumber - 1));
            bytesForRead = bytesNumber - ...
                (length(firstDataLine) - length('#n') - digitsNumber);
            availableBytesNumber = obj.virtualObject.NumBytesAvailable;
            while availableBytesNumber ~= bytesForRead
                availableBytesNumber = obj.virtualObject.NumBytesAvailable;
            end
            response = read(obj.virtualObject,bytesForRead,"char");
            obj.lastReadWaveform = [firstDataLine,response];
        end
        function obj = saveWaveform(obj,userText)
            obj.lastReadWaveformPath = [obj.folder,filesep,userText,...
                createFilename(now,'waveform_'),'.csv'];
            fileID = fopen(obj.lastReadWaveformPath,'w');
            fwrite(fileID,obj.lastReadWaveform,'char');
            fclose(fileID);
        end
        function obj = readAnalysisEDFANF(obj,trace)
            writeline(obj.virtualObject,[obj.TRACE_ACTIVE_X,trace]);
            writeline(obj.virtualObject,[obj.TRACE_VISIBLE_X,trace,' 1']);
            writeline(obj.virtualObject, obj.ANALYSIS_MODE_NF);
            writeline(obj.virtualObject, obj.ANALYSIS_START);
            writeline(obj.virtualObject, obj.ANALYSIS_READ);
            response = readline(obj.virtualObject);
            resultAnalysisNF_charArray = char(response);
            resultAnalysisNF_cellCharArray = strsplit(resultAnalysisNF_charArray,',');
            resultAnalysisNF_numArray = cellfun(@str2double,resultAnalysisNF_cellCharArray);
            ch_num = resultAnalysisNF_numArray(1);
            resultAnalysisNF = resultAnalysisNF_numArray(2:end);
            parametersNumber = length(obj.NAMES_ANALYSIS_NF);
            resultAnalysisNF_reshaped = reshape(resultAnalysisNF,...
                parametersNumber,ch_num)';
            obj.lastReadAnalysisEDFANF = array2table(resultAnalysisNF_reshaped,...
                'VariableNames', obj.NAMES_ANALYSIS_NF);
        end
        function saveAnalysisEDFANF(obj,userText)
            filename = [obj.folder,filesep,userText,...
                createFilename(now,'EDFA_NF_'),'.csv'];
            writetable(obj.lastReadAnalysisEDFANF,filename);
        end
        function power = readPower(obj,trace)
            writeline(obj.virtualObject,[obj.TRACE_ACTIVE_X,trace]);
            writeline(obj.virtualObject,[obj.TRACE_VISIBLE_X,trace,' 1']);
            writeline(obj.virtualObject, obj.ANALYSIS_MODE_POWER);
            writeline(obj.virtualObject, obj.ANALYSIS_START);
            writeline(obj.virtualObject, obj.ANALYSIS_READ);
            response = readline(obj.virtualObject);
            power = str2double(response);
        end
        function plotWaveform(obj,app)
            setLabelsAxes(app,'Spectrum (log)','Wavelength, nm','Power, dBm');
            [x, y] = prepareForPlotDataFromOSA(obj.lastReadWaveformPath);
            plotAxes(app, x, y);
        end
        function obj = deleteVirtualObject(obj)
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
    methods (Access = private)
        function obj = connect(obj)
            obj.virtualObject = tcpclient(obj.ipAddress, obj.PORT, 'Timeout', obj.timeOut);
            configureTerminator(obj.virtualObject,"CR/LF");
            writeline(obj.virtualObject,obj.CONNECT_USERNAME);
            usernameResponse = readline(obj.virtualObject);
            writeline(obj.virtualObject,obj.PASSWORD);
            passwordResponse = readline(obj.virtualObject);
            obj.isReady = passwordResponse == obj.PASSWORD_RESPONSE;
            if obj.isReady == false
                error('OSA not ready');
            end
        end
        function obj = startRequests(obj)
            writeline(obj.virtualObject,obj.REQUESTS_MODE);
            writeline(obj.virtualObject,obj.CALC_MODE_AUTO);
            writeline(obj.virtualObject,obj.SWTHRESH);
            writeline(obj.virtualObject,obj.LMARKER_AOFF);
        end
    end
end