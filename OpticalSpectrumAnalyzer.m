classdef OpticalSpectrumAnalyzer
    properties
        ipAddress
        timeOut
        isReady
        virtualObject
        waveformTrace
        folder
        userText
    end
    properties (Constant)
        username = 'admin'
        password = 'admin'
        port = 10001;
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
    properties %временные переменные
        minNF
        meanNF
        maxNF
        minGAIN
        meanGAIN
        maxGAIN
        deltaGAIN
    end
    methods
        % Конструктор класса
        function obj = OpticalSpectrumAnalyzer(app)
            if nargin > 0
                obj.folder = app.folder;
                obj.userText = app.userText;
                obj.ipAddress = app.IPaddressEditField.Value;
                obj.timeOut = app.TimeoutEditField.Value;
                obj.referenceTrace = app.ReferencetraceDropDown.Value;
                obj.waveformTrace = app.WaveformtraceDropDown.Value;
                obj.virtualObject = tcpclient(obj.ipAddress, obj.port, 'Timeout', obj.timeOut);
                configureTerminator(obj.virtualObject,"CR/LF");
                reguest = ['open "' obj.username '"']; % создание запроса для ОСА
                writeline(obj.virtualObject,reguest); % отправка запроса
                usernameResponse = readline(obj.virtualObject); % получение ответа
                writeline(obj.virtualObject,obj.password);
                passwordResponse = readline(obj.virtualObject);
                obj.isReady = passwordResponse == "ready";
                %
                obj.numberMeasurement = 0;
                obj.waveform = {};
                obj.analysisEDFANF = {};
                % Установка формата команд
                writeline(obj.virtualObject,'CFORM1');
                % Установка авто измерения в вкл
                writeline(obj.virtualObject, ':CALCULATE:AUTO ON'); % 7-52
                % Расчет спектральной ширины по уровню 3 db
                writeline(obj.virtualObject, ':CALCULATE:PARAMETER:SWTHRESH: TH 3.00DB');
                % Очищение всех маркеров
                writeline(obj.virtualObject, ':CALCulate:LMARker:AOFF'); %
            end
        end
        % Установка настроек снятия спектра
        function obj = applySettings(obj,app)
            % Установка начальной длины волны
            if app.CheckBoxStartWl.Value
                obj.startWavelength = app.StartwavelengthEditField.Value;
                request = [':SENSe:WAVelength:STARt ' obj.startWavelength 'NM'];
                writeline(obj.virtualObject, request);
            end
            % Установка конечной длины волны
            if app.CheckBoxStopWl.Value
                obj.stopWavelength = app.StopwavelengthEditField.Value;
                request = [':SENSe:WAVelength:STOP ' obj.stopWavelength 'NM'];
                writeline(obj.virtualObject, request);
            end
            % Установка чувствительности
            if app.CheckBoxSenseMode.Value
                obj.senseMode = app.SensemodeEditField.Value;
                senseModeRequest = [':SENSe:SENSe ' obj.senseMode];
                writeline(obj.virtualObject, senseModeRequest);
            end
            % Установка разрешения IMAQ6370C-17EN p.7-85
            if app.CheckBoxResolution.Value
                obj.resolution = app.ResolutionEditField.Value;
                resolutionRequest = [':SENSe:BANDwidth ' obj.resolution 'NM'];
                writeline(obj.virtualObject, resolutionRequest);
            end
            % Установка опорного уровня 7-75
            if app.CheckBoxReferenceLevel.Value
                obj.referenceLevel = app.ReflevelEditField.Value;
                referenceLevelRequest = [':DISPlay:TRACe:Y1:RLEVel ' obj.referenceLevel 'dbm'];
                writeline(obj.virtualObject, referenceLevelRequest);
            end
            % Установка шкалы уровня
            if app.CheckBoxLevelScale.Value
                obj.levelScale = app.LevelscaleEditField.Value;
                request = [':DISPlay:TRACe:Y1:PDIVision ' obj.levelScale 'DB'];
                writeline(obj.virtualObject, request);
            end
        end
        % Запись спектра на заданной трассе
        function writeSelectedTrace(obj,trace)
            % Выбор активной трассы
            active_trace = strcat(':TRACe:ACTive TR',trace);
            writeline(obj.virtualObject,active_trace);
            % Сделать выбранную трассу видимой
            disp_trace = strcat(':TRACe:STATe:TR',trace,' 1');
            writeline(obj.virtualObject,disp_trace);
            % Создание массива с названиями всех трасс
            all_traces = 'ABCDEFG';
            % Ставим 1 на месте выбранной трассы и 0 на остальных
            logic_traces = trace == all_traces;
            % Отправляем ОСА информацию о том, что выбранную трассу нужно
            % поставить в режим записи, а остальные трассы зафиксировать
            for i = 1:length(logic_traces)
                if logic_traces(i)
                    write_or_fix = ' WRITE';
                else
                    write_or_fix = ' FIX';
                end
                write_or_fix_trace = [':TRACE:ATTRIBUTE:TR' all_traces(i) write_or_fix];
                writeline(obj.virtualObject,write_or_fix_trace);
            end
            % Выбор режима и снятие спектра
            flush(obj.virtualObject);
            writeline(obj.virtualObject, ':init:smode 1'); % одиночное снятие спектра
            writeline(obj.virtualObject, ':init');         % начать снятие
            % Ожидаем пока спектр будет снят
            status = '0';
            while ~isequal(status,'1')
                writeline(obj.virtualObject, ':stat:oper:even?'); % запрос статуса снятия
                status = readline(obj.virtualObject);
                status = char(status);%convertStringsToChars(status);
            end
            % Фиксируем выбранную трассу
            fix_trace_ref = [':TRACE:ATTRIBUTE:TR' trace ' FIX'];
            writeline(obj.virtualObject,fix_trace_ref);
        end
        % Функция записи опорного сигнала
        function writeReferenceTrace(obj)
            writeSelectedTrace(obj,obj.referenceTrace);
        end
        % Функция записи спектра
        function writeWaveformTrace(obj)
            writeSelectedTrace(obj,obj.waveformTrace);
        end
        % Чтение рабочей области из файла на ОСА
        function obj = readWaveform(obj)
            % Сохранение на ОСА
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
        % Выставление оффсетов
        function applyOffsetSettings(obj,offsetValue,type)
            % offsetValue = '' (str)
            % type = 'power','in','out'
            if isequal(type,'power')
                request = [':CALCulate:PARameter:POWer:OFFset ' offsetValue];
            elseif isequal(type,'in')
                request = [':CALCulate:PARameter:NF:IOFFset ' offsetValue];
            elseif isequal(type,'out')
                request = [':CALCulate:PARameter:NF:OOFFset ' offsetValue];
            end
            writeline(obj.virtualObject,request);
            % manual 7-32
            % ":PARameter:NF:IOFFset <NRf>[DB]"  % 7-61 manual
            % ":PARameter:NF:OOFFset <NRf>[DB]"  % 7-62 manual
            % ":PARameter:POWer:OFFSet <NRf>[DB]"  % 7-64 manual
            % <NRf>[DB] = 10.00
        end
        % Отключение соединения
        function obj = deleteVirtualObject(obj)
            % сохранение?
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end