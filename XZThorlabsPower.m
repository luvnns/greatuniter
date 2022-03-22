classdef ThorlabsPower
    properties
        power % значение которое необходимо записать в основной массив данных
        number % номер измерения
        name % значение мощности в виде строки
    end
    properties
        virtualObject
        operationWave
        meanInt
        loss
        visaAddress
        filter
        units
    end
    
    methods
        function obj = ThorlabsPower(operationWave,meanInt,loss,visaAddress,filter,units)
            obj.number = 0;
            obj.name = {};
            obj.operationWave = operationWave;
            obj.meanInt = meanInt;
            obj.loss = loss;
            obj.visaAddress = visaAddress;
            obj.filter = filter;
            obj.units = units;
            obj.virtualObject = visa('ni',visaAddress);%USB0::0x1313::0x80B0::P3000699::INSTR
            fopen (obj.virtualObject);
        end
        function obj = setParam(obj)
            % считывание типа подключенного сенсора
            fprintf(obj.virtualObject, 'SYSTem:SENSor:IDN?');%запрос информации о подключенном сенсоре
            out = fscanf(obj.virtualObject);
            % ответ
            % S144C,13112218,22-Nov-2013,1,18,289
            % <sn>,<cal_msg>,<type>,<subtype>,<flags>
            % <name>        Sensor name in string response format
            % <sn>            Sensor serial number in string response format
            % <cal_msg>     calibration message in string response format
            % <type>           Sensor type in NR1 format
            % <subtype>     Sensor subtype in NR1 format
            % <flags>         Sensor flags as bitmap in NR1 format. 1 - axe2 sensor
            sensor_info = textscan(out,'%s%s%s%s%s%s','delimiter',',');
            sensor_type = sensor_info{1,1};
            sensor_type = sensor_type{1,1};
            
            % установка длины волны
            operation_wave = ['SENSe:CORRection:WAVelength ' obj.operationWave];
            fprintf(obj.virtualObject, operation_wave);
            fprintf(obj.virtualObject, 'SENSe:CORRection:WAVelength?');%запрос оперируемой длины волны
            out = fscanf(obj.virtualObject);
            
            % установка единиц измерения
            out = ['SENSe:POWer:UNIT ' obj.units];
            fprintf(obj.virtualObject, out);
            fprintf(obj.virtualObject, 'SENSe:POWer:UNIT?');
            out = fscanf(obj.virtualObject);
            
            % установка усреднения
            out = ['SENSe:AVERage:COUNt ' obj.meanInt];
            fprintf(obj.virtualObject, out); %усреднение
            fprintf(obj.virtualObject, 'SENSe:AVERage:COUNt?');
            out = fscanf(obj.virtualObject);
            
            % установка аттенюации
            out = ['SENSe:CORRection:LOSS ' obj.loss];
            fprintf(obj.virtualObject, out); %установка аттенюации в дБ
            fprintf(obj.virtualObject, 'SENSe:CORRection:LOSS?');
            out = fscanf(obj.virtualObject);
            
            % спектральный фильтр
            out = ['INPut:PDIode:FILTer:LPASs:STATe ' obj.filter];
            fprintf(obj.virtualObject, out);%выключить спектральный фильтр (10Hz) to (100kHz)
            fprintf(obj.virtualObject, 'INPut:PDIode:FILTer:LPASs:STATe?');
            out = fscanf(obj.virtualObject);
        end
        function obj = readData(obj)
            flushinput(obj.virtualObject);
            flushoutput(obj.virtualObject);
            obj.number = obj.number + 1;
            fprintf(obj.virtualObject, 'INITiate');
            fprintf(obj.virtualObject, 'MEASure:POWer');
            fprintf(obj.virtualObject, 'READ?');
            out = fscanf(obj.virtualObject);
            out = str2double(out);

            if out < 1000
                obj.power(obj.number) = out;
                
                % генерирование строчки для имени файла спектра
                text_1 = 'error';
                value = obj.power(obj.number);
                if value >= 1
                    text_1 = 'W';
                    value = value;
                end
                if value < 1 && value >= 10^-3
                    text_1 = 'mW';
                    value = value * 10^3;
                end
                if value < 10^-3 && value >= 10^-9
                    text_1 = 'uW';
                    value = value * 10^6;
                end
                if value < 10^-9 && value >= 10^-16
                    text_1 = 'nW';
                    value = value * 10^9;
                end
                if value < 10^-16
                    text_1 = '';
                    value = 0;
                end
                namePower = num2strForPrint(value);
                % значение для имени файла
                obj.name(obj.number) = {[namePower text_1]};
            else
                obj = readData(obj);
            end
        end
        % Отключение от прибора
        function obj = deleteVirtualObject(obj)
            fclose(obj.virtualObject);
            %delete(obj.virtualObject);
            %clear obj.virtualObject;
        end
    end
end