classdef OpticalPowerMeterArr
    properties
        opticalPowerMeters
    end
    methods
        % Конструктор
        function obj = OpticalPowerMeterArr(app)
            comPortStr = app.OPMcomPortsEditField.Value;
            obj.opticalPowerMeters = createCom(comPortStr,@OpticalPowerMeterRubin);
        end
        % Информация о подключении к COM-портам
        function output = getInfoOpenComArr(obj)
            output = repeatFunc(obj.opticalPowerMeters,@getInfoOpenCom);
        end
        % Вывод длины волны всех ИОМ
        function output = getInfoWavelengthArr(obj)
            output = repeatFunc(obj.opticalPowerMeters,@getInfoWavelength);
        end
        % Чтение мощности со всех ИОМ
        function obj = readPowerdBmArr(obj)
            obj.opticalPowerMeters = repeatFunc(obj.opticalPowerMeters,@readPowerdBm);
        end
        % Создаем информацию о мощности в виде строки
        function output = getInfoPowerArr(obj)
            output = repeatFunc(obj.opticalPowerMeters,@getInfoPowerdBm);
        end
        % Закрытие COM-портов
        function obj = deleteVirtualObjectArr(obj)
            obj.opticalPowerMeters = repeatFunc(obj.opticalPowerMeters,@deleteVirtualObject);
        end
        % Информация о закрытии COM-портов
        function output = getInfoCloseComArr(obj)
            output = repeatFunc(obj.opticalPowerMeters,@getInfoCloseCom);
        end
    end
end



