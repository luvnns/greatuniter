classdef OpticalPowerMeterRubin
    properties
        comPort
        virtualObject
        wavelength
        lastReadPower
    end
    properties (Constant)
        baudRate = 9600
        powerMinLimit = -60
    end
    properties
        numberMeasurement
        powerdBm
        powerW%%%
        time
    end
    methods
        % Конструктор класса
        function obj = OpticalPowerMeterRubin(comPort)
            if nargin > 0
                obj.comPort = comPort;
                obj.virtualObject = serialport(obj.comPort,obj.baudRate);
                obj.numberMeasurement = 0;
                wavelength = char(hex2dec('7A'));
                write(obj.virtualObject,wavelength,"char");
                read_wavelength = read(obj.virtualObject,2,"uint8");
                obj.wavelength = read_wavelength(1)*256+read_wavelength(2);
            end
        end
        % Информация о закрытии COM-порта
        function str = getInfoOpenCom(obj)
            name = obj.comPort;
            str = strcat("OPM on ",name," connected;");
        end
        % Создаем информацию о длине волны в виде строки
        function str = getInfoWavelength(obj)
            name = obj.comPort;
            param = obj.wavelength;
            param = num2strForPrint(param);
            str = strcat("OPM on ",name," detect at ",param," nm;");
        end
        % Чтение мощности в дБм
        function obj = readPowerdBm(obj)
            obj.numberMeasurement = obj.numberMeasurement + 1;
            i = obj.numberMeasurement; % для краткости записи
            power = char(hex2dec('82'));
            write(obj.virtualObject,power,"char");
            read_power = read(obj.virtualObject,7,"uint8");
            obj.powerdBm(i) = (read_power(1)*256+read_power(2))/100;
            if read_power(3) == 1
                obj.powerdBm(i) = obj.powerdBm(i)*(-1);
            end
            if obj.powerdBm(i) < obj.powerMinLimit
                obj.powerdBm(i) = obj.powerMinLimit;
            end
            obj.lastReadPower = obj.powerdBm(i);
            obj.time(i) = now;
        end
        % Создаем информацию о мощности в виде строки
        function str = getInfoPowerdBm(obj)
            name = obj.comPort;
            param = obj.powerdBm(end);
            param = num2strForPrint(param);
            str = strcat("OPM on ",name," detect power ",param," dBm;");
        end
        % Чтение мощности в Ватт с автоопределением порядка
        
        % Создаем информацию о мощности в виде строки
        
        % 
        % Создаем информацию о длине волны в виде строки
        function obj = nextWavelength(obj)
            nextWavelength = char(hex2dec('7B'));
            write(obj.virtualObject,nextWavelength,"char");
            read_wavelength = read(obj.virtualObject,2,"uint8");
            obj.wavelength = read_wavelength(1)*256+read_wavelength(2);
        end
        % Закрытие COM-порта
        function obj = deleteVirtualObject(obj)
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
        % Информация о закрытии COM-порта
        function str = getInfoCloseCom(obj)
            name = obj.comPort;
            str = strcat("OPM on ",name," disconnected;");
        end
    end
end