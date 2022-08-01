classdef OpticalPowerMeterThorlabs
    properties
        virtualObject
        lastReadPower
    end
    properties (Constant)
        visaAddress = 'USB0::0x1313::0x80B0::P3000699::INSTR'
        units = 'DBM'
    end
    properties
        numberMeasurement
        powerdBm
        time
    end
    properties
        wavelength
        averaging
        loss
        filter
    end
    
    methods
        % Конструктор класса
        function obj = OpticalPowerMeterThorlabs(app)
            if nargin > 0
                obj.virtualObject = visa('ni',visaAddress);
                obj.numberMeasurement = 0;
                fopen (obj.virtualObject);
                
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
                
                % установка единиц измерения
                out = ['SENSe:POWer:UNIT ' obj.units];
                fprintf(obj.virtualObject, out);
                fprintf(obj.virtualObject, 'SENSe:POWer:UNIT?');
                out = fscanf(obj.virtualObject);
            end
        end
        function obj = applySettings(obj,app)
            % Установка длины волны
            if app.WavelengthCheckBox.Value
                obj.wavelength = app.WavelengthEditField.Value;
                operation_wave = ['SENSe:CORRection:WAVelength ' obj.wavelength];
                fprintf(obj.virtualObject, operation_wave);
                fprintf(obj.virtualObject, 'SENSe:CORRection:WAVelength?');%запрос оперируемой длины волны
                out = fscanf(obj.virtualObject);
            end
            % установка усреднения
            if app.AveragingCheckBox.Value
                obj.averaging = app.AveragingEditField.Value;
                out = ['SENSe:AVERage:COUNt ' obj.averaging];
                fprintf(obj.virtualObject, out); %усреднение
                fprintf(obj.virtualObject, 'SENSe:AVERage:COUNt?');
                out = fscanf(obj.virtualObject);
            end
            if app.WavelengthCheckBox.Value
                obj.wavelength = app.WavelengthEditField.Value;
                operation_wave = ['SENSe:CORRection:WAVelength ' obj.wavelength];
                fprintf(obj.virtualObject, operation_wave);
                fprintf(obj.virtualObject, 'SENSe:CORRection:WAVelength?');%запрос оперируемой длины волны
                out = fscanf(obj.virtualObject);
            end
            % установка аттенюации
            if app.LossCheckBox.Value
                obj.loss = app.LossEditField.Value;
                out = ['SENSe:CORRection:LOSS ' obj.loss];
                fprintf(obj.virtualObject, out); %установка аттенюации в дБ
                fprintf(obj.virtualObject, 'SENSe:CORRection:LOSS?');
                out = fscanf(obj.virtualObject);
            end
            % спектральный фильтр
            if app.FilterCheckBox.Value
                if isequal(app.FilterDropDown.Value,'off')
                    obj.filter = '1';
                elseif isequal(app.FilterDropDown.Value,'on')
                    obj.filter = '0';
                end
                out = ['INPut:PDIode:FILTer:LPASs:STATe ' obj.filter];
                fprintf(obj.virtualObject, out);%выключить спектральный фильтр (10Hz) to (100kHz)
                fprintf(obj.virtualObject, 'INPut:PDIode:FILTer:LPASs:STATe?');
                out = fscanf(obj.virtualObject);
            end
        end
        function obj = readPowerdBm(obj)
            flushinput(obj.virtualObject);
            flushoutput(obj.virtualObject);
            obj.numberMeasurement = obj.numberMeasurement + 1;
            fprintf(obj.virtualObject, 'INITiate');
            fprintf(obj.virtualObject, 'MEASure:POWer');
            fprintf(obj.virtualObject, 'READ?');
            out = fscanf(obj.virtualObject);
            out = str2double(out);
            if out < 1000
                obj.powerdBm(obj.numberMeasurement) = out;
                obj.lastReadPower = out;
                obj.time(obj.numberMeasurement) = now;
            else
                obj = readPowerdBm(obj);
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