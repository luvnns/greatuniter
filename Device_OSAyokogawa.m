classdef Device_OSAyokogawa
    properties (Constant)
        PORT = 10001;
        PASSWORD_RESPONSE = "ready"
        TRACES = 'ABCDEFG';
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
        waveformTrace
        folder
        userText
    end
    properties
        startWavelength
        stopWavelength
        senseMode
        resolution
        levelScale
        referenceTrace
        referenceLevel
        waveformFile
    end
    properties
        waveform
        analysisEDFANF
        power
        time
        numberMeasurement
    end
    properties %временные переменные переделать в методы
        minNF
        meanNF
        maxNF
        minGAIN
        meanGAIN
        maxGAIN
        deltaGAIN
    end
    methods
        function obj = Device_OSAyokogawa(appStruct)
            % Constructor of class
            obj.folder = appStruct.folder;
            obj.userText = appStruct.userText;
            obj.ipAddress = appStruct.IPaddressEditField.Value;
            obj.timeOut = appStruct.TimeoutEditField.Value;
            obj.referenceTrace = appStruct.ReferencetraceDropDown.Value;
            obj.waveformTrace = appStruct.WaveformtraceDropDown.Value;
            try
                obj = connect(obj);
                obj = startRequests(obj);
            catch
                disp()
            end

            obj.numberMeasurement = 0;
            obj.waveform = {};
            obj.analysisEDFANF = {};
        end
    end

    methods (Access = private, Hidden)
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

    methods
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
        function writeWaveformOnTrace(obj,trace)
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
            flush(obj.virtualObject);
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
        function obj = readWaveform(obj)
            % Сохранение на ОСА   WRITE_WAVEFORM_SAVE
            write_spectr = [':mmem:stor:trac TR' obj.waveformTrace ',csv,"test",int'];
            writeline(obj.virtualObject, write_spectr);
            % Чтение из ОСА в ПК
            flush(obj.virtualObject);
            writeline(obj.virtualObject, ':mmem:data? "test.csv",int');
            data_first_line = readline(obj.virtualObject);
            % Ответ приходит в виде строки
            % "#612246870BCSV  ", у которой
            % на первом месте - символ "#",
            % на втором - цифра n (количество
            % цифр дальше для записи числа
            % байт информации),
            % начиная с 3 символа идет
            % n-значное число, показывающее
            % сколько после этого числа будет
            % байт информации.
            % Подробнее см. инструкцию к ОСА.

            % Перевод строки в массив символов
            % (удобнее для сравнения и вычисления длины)
            data_first_line = char(data_first_line);
            % Проверка полученных данных
            if ~isequal(data_first_line(1),'#')
                disp('ERROR: wrong response!')
            end
            % Вычисление количества байт, содержащих информацию о спектре
            % (из информации в первой строке)
            length_first_line = length(data_first_line);
            digits_number = str2double(data_first_line(2));
            bytes_number = str2double(data_first_line(3:3 + digits_number - 1));
            bytes_to_be_read = bytes_number - ...
                (length_first_line - length('#n') - digits_number);
            % Ожидание, когда придёт нужное количество байт
            bytes_number_available = obj.virtualObject.NumBytesAvailable;
            while bytes_number_available ~= bytes_to_be_read
                bytes_number_available = obj.virtualObject.NumBytesAvailable;
            end
            % Чтение спектра в переменную
            obj.numberMeasurement = obj.numberMeasurement + 1;
            i = obj.numberMeasurement; % для краткости записи
            receivedWaveform = read(obj.virtualObject,bytes_to_be_read,"char");
            receivedWaveform = [data_first_line receivedWaveform];
            obj.waveform(i) = {receivedWaveform};
            obj.time(i) = now;
            filename = createFilename('_waveform',obj.time(i));
            obj.waveformFile = filename;
        end
        function obj = readAndSaveReference(obj)
            % Сохранение на ОСА
            write_spectr = [':mmem:stor:trac TR' obj.referenceTrace ',csv,"test",int'];
            writeline(obj.virtualObject, write_spectr);
            % Чтение из ОСА в ПК
            flush(obj.virtualObject);
            writeline(obj.virtualObject, ':mmem:data? "test.csv",int');
            data_first_line = readline(obj.virtualObject);
            % Ответ приходит в виде строки
            % "#612246870BCSV  ", у которой
            % на первом месте - символ "#",
            % на втором - цифра n (количество
            % цифр дальше для записи числа
            % байт информации),
            % начиная с 3 символа идет
            % n-значное число, показывающее
            % сколько после этого числа будет
            % байт информации.
            % Подробнее см. инструкцию к ОСА.

            % Перевод строки в массив символов
            % (удобнее для сравнения и вычисления длины)
            data_first_line = char(data_first_line);
            % Проверка полученных данных
            if ~isequal(data_first_line(1),'#')
                disp('ERROR: wrong response!')
            end
            % Вычисление количества байт, содержащих информацию о спектре
            % (из информации в первой строке)
            length_first_line = length(data_first_line);
            digits_number = str2double(data_first_line(2));
            bytes_number = str2double(data_first_line(3:3 + digits_number - 1));
            bytes_to_be_read = bytes_number - ...
                (length_first_line - length('#n') - digits_number);
            % Ожидание, когда придёт нужное количество байт
            bytes_number_available = obj.virtualObject.NumBytesAvailable;
            while bytes_number_available ~= bytes_to_be_read
                bytes_number_available = obj.virtualObject.NumBytesAvailable;
            end
            % Чтение спектра в переменную
            receivedWaveform = read(obj.virtualObject,bytes_to_be_read,"char");
            receivedWaveform = [data_first_line receivedWaveform];
            filename = createFilename('reference',now);
            referenceFile = [obj.folder filename '.csv'];
            % Сохранение спектра на ПК
            fileID = fopen(referenceFile,'w');
            fwrite(fileID,receivedWaveform,'char');
            fclose(fileID);
        end
        % Сохранение спектра на ПК
        function obj = saveWaveformToPC(obj,strForWaveform)
            obj.waveformFile = [obj.folder strForWaveform obj.waveformFile '.csv'];
            %disp(obj.waveformFile)
            lastWaveform = obj.waveform{end};
            fileID = fopen(obj.waveformFile,'w');
            fwrite(fileID,lastWaveform,'char');
            fclose(fileID);
        end
        % Построение графика спектра
        function plotWaveformYoko(obj,app)
            %disp(obj.waveformFile)
            tableWaveform = readmatrix(obj.waveformFile);
            forSearch = tableWaveform(:,1);
            searchArray = find(isnan(forSearch));
            row = searchArray(end) + 1; %первая строка графика
            tableWaveform = tableWaveform(row:end,:);
            figureWaveform = tableWaveform;
            x = figureWaveform(:,1);
            y = figureWaveform(:,2);
            %yLine = dBm2mkW(y);
            title(app.UIAxesLog,'Spectrum (log)');
            xlabel(app.UIAxesLog,'Wavelength, nm');
            ylabel(app.UIAxesLog,'Power, dBm');
            plot(app.UIAxesLog,x,y);
            %             title(app.UIAxesLine,'Spectrum (line)');
            %             xlabel(app.UIAxesLine,'Wavelength, nm');
            %             ylabel(app.UIAxesLine,'Power, mkW');
            %             plot(app.UIAxesLine,x,yLine);
        end
        % Чтение данных анализа EDFA-NF из файла на ОСА
        function obj = readAnalysisEDFANF(obj)
            % Выбор активной трассы
            active_trace = strcat(':TRACe:ACTive TR',obj.waveformTrace);
            writeline(obj.virtualObject, active_trace);
            % Выбор алгоритма анализа (NF)
            writeline(obj.virtualObject, ':CALCulate:CATegory NF');
            writeline(obj.virtualObject, ':calc');
            % Запрос результатов расчета EDFA-NF
            writeline(obj.virtualObject, ':calc:data?');
            % Чтение строки - результата расчета
            OSA_edfa_nf_str = readline(obj.virtualObject);
            % Выходной формат <ch num>, <center wl>, <input lvl>,
            % <output lvl>, <ase lvl>, <resoln>, <gain>, <nf>,...
            % Создаем cell-array из названий полученных данных
            OSA_edfa_nf_names = {'center_wl','input_lvl',...
                'output_lvl','ase_lvl','resoln','gain','nf'};
            % Перевод строки в символы
            OSA_edfa_nf_char = char(OSA_edfa_nf_str);
            % Деление символов на ячейки, разделитель - запятая
            OSA_edfa_nf_cell = strsplit(OSA_edfa_nf_char,',');
            % Создание таблицы из массива строк
            % OSA_edfa_nf_table = cell2table(OSA_edfa_nf_cell(1:8),...
            %                                'VariableNames', OSA_edfa_nf_names);
            % Перевод cell в массив чисел
            OSA_edfa_nf_arr = cellfun(@str2double,OSA_edfa_nf_cell);
            % Создание таблицы из массива чисел
            ch_num = OSA_edfa_nf_arr(1);
            index = 2;
            for i = 1:ch_num
                OSA_edfa_nf(i,:) = OSA_edfa_nf_arr(index:index+6);
                index = index + 7;
            end
            i = obj.numberMeasurement;
            obj.analysisEDFANF(i) = {array2table(OSA_edfa_nf,...
                'VariableNames', OSA_edfa_nf_names)};

            % К данным в таблице можно обращаться так: OSA_edfa_nf_table.ch_num
            % Вместо ch_num можно использовать другое название столбца
            edfanfForVar = obj.analysisEDFANF(i);
            edfanfForVar = edfanfForVar{1};
            %save('test.mat','edfanfForVar');
            obj.minNF = min(edfanfForVar{:,'nf'});
            obj.meanNF = mean(edfanfForVar{:,'nf'});
            obj.maxNF = max(edfanfForVar{:,'nf'});
            obj.minGAIN = min(edfanfForVar{:,'gain'});
            obj.meanGAIN = mean(edfanfForVar{:,'gain'});
            obj.maxGAIN = max(edfanfForVar{:,'gain'});
            obj.deltaGAIN = max(edfanfForVar{:,'gain'}) - min(edfanfForVar{:,'gain'});
        end
        % Сохранение данных анализа EDFA-NF
        function saveAnalysisEDFANF(obj,strForWaveform)
            tableEDFANF = obj.analysisEDFANF{end};
            filename = createFilename('edfanf',obj.time(end));
            fullFilename = [obj.folder strForWaveform '_' filename '.xlsx'];
            writetable(tableEDFANF,fullFilename)
        end
        % Чтение мощности
        function obj = readPower(obj)
            % Выбор активной трассы
            active_trace = strcat(':TRACe:ACTive TR',obj.waveformTrace);
            writeline(obj.virtualObject, active_trace);
            % Выбор алгоритма анализа POWER (7-49 manual)
            writeline(obj.virtualObject, ':CALCulate:CATegory POWer');
            writeline(obj.virtualObject, ':calc');
            % Запрос результатов расчета POWER
            writeline(obj.virtualObject, ':calc:data?');
            OSA_power_str = readline(obj.virtualObject);
            i = obj.numberMeasurement;
            obj.power(i) = double(OSA_power_str);
        end
        % Чтение мощности
        function refPower = readReferencePower(obj)
            % Выбор активной трассы
            active_trace = strcat(':TRACe:ACTive TR',obj.referenceTrace);
            writeline(obj.virtualObject, active_trace);
            % Выбор алгоритма анализа POWER (7-49 manual)
            writeline(obj.virtualObject, ':CALCulate:CATegory POWer');
            writeline(obj.virtualObject, ':calc');
            % Запрос результатов расчета POWER
            writeline(obj.virtualObject, ':calc:data?');
            OSA_power_str = readline(obj.virtualObject);
            %i = obj.numberMeasurement;
            %obj.power(i) = double(OSA_power_str);
            refPower = double(OSA_power_str);
        end
        % Сохранение мощности
        function savePower(obj)
            filename = createFilename('power',obj.time(end));
            fullFilename = [obj.folder obj.userText '_' filename '.xlsx'];
            writematrix(obj.power,fullFilename);
        end
        function obj = deleteVirtualObject(obj)
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end