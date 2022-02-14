classdef comDevice
    properties
        comPort
        baudRate
        virtualObject % виртуальный объект устройства
        filename2read % название файла, из которого берутся переменные
        filename2write % название файла, которое создается для одного цикла чтения
        time % массив времени
        data % массив (cell) данных
        numberC % кол-во столбцов в таблице из файла
        i % номер измерения
    end
    methods
        % Эту функцию обязательно нужно запустить, чтобы создать объект и
        % работать с ним
        function obj = comDevice(comPort,baudRate,filename,fileformat)
            % Передача параметров в объект
            obj.filename2read = [filename '.' fileformat];
            obj.filename2write = [createFilename(filename,now) '.' fileformat];
            obj.comPort = comPort;
            obj.baudRate = baudRate;
            % Создание подключения по COM-порту
            obj.virtualObject = serialport(obj.comPort,obj.baudRate);
            configureTerminator(obj.virtualObject,"CR/LF");
            flush(obj.virtualObject);
            % Чтение первой строки
            data = readline(obj.virtualObject);
            % Чтение названий столбцов из таблицы для чтения и определение
            % их количества
            variableNames = readtable(obj.filename2read,'ReadVariableNames',0);
            [numberRow,numberCol] = size(variableNames);
            obj.numberC = numberCol;
            % Задание начальных параметров
            obj.i = 0;
            obj.data = {};
            figure;
        end
        % Функция читает данные один раз и добавляет строку в таблицу,
        % точку на график
        function obj = readData(obj)
            % Обновление номера измерения
            obj.i = obj.i + 1;
            % Чтение данных
            data_str = readline(obj.virtualObject);
            % Заполнение ячейки массива времени
            obj.time(obj.i) = now;
            % Преобразование прочитанных данных
            data_str = strsplit(data_str,';');
            data_num = str2double(data_str);
            % Запись данных в ячейку data
            obj.data{obj.i} = data_num;
            % Добавление в массив данных столбца времени
            data_num(obj.numberC-1) = obj.time(obj.i);
            
            % Условие добавлено потому, что считается разница
            % между текущим и предыдущим значением
            if obj.i > 1
                % Вычисление разницы времени
                time_diff = (obj.time(obj.i)-obj.time(obj.i-1));
                % Перевод разницы в мс, представленные тремя символами
                time_diff_in_msec = str2double(datestr(time_diff, 'FFF'));
                % Добавление в массив данных столбца разницы времени
                data_num(obj.numberC) = time_diff_in_msec;
                % Добавление всей строки данных в таблицу
                writematrix(data_num,obj.filename2write,"WriteMode","append");
            end
            % Построение точки на графике
            plot(obj.time(obj.i),data_num(1),'ob');
            hold on;
        end
        function calcMeanMS(obj)
            % Чтение матрицы из файла
            forMeanMS = readmatrix(obj.filename2write);
            % Вычисление среднего значения миллисекунд
            meanMS = mean(forMeanMS(:,obj.numberC))
        end
        % Закрытие COM-порта
        function obj = deleteVirtualObject(obj)
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end