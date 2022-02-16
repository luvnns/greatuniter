classdef FPGA
    properties
        virtualObject
        interface
        addressTable
        lastRead
    end
methods (Access = private)
    function obj = dataExchange(obj)

    end
end
    methods
        % Конструктор класса
        function obj = FPGA(app)
            obj.interface = app.InterfaceDropDown.Value;
            obj.addressTable = createAddressTable(app.Addresstable.Value{1});
            if isequal(obj.interface,'JTAG')
                obj.virtualObject =  tcpclient('localhost', 2540);
            elseif isequal(obj.interface,'Ethernet')
                error('Ethernet is not ready');
            end
            name = 'CC_TEST';
            obj = readDataFromFPGA(obj,name); 
        end
        % Чтение данных по названию ячейки
        function obj = readDataFromFPGA(obj,name)
            type = whatType(obj,name);
            if ~isequal(type,'NaT')
                currentRow = obj.addressTable(name,:);
                number_of_bits_in_num = str2double(currentRow.Number_of_bits{1,1});
                addr = currentRow.Address{1,1};
                if isempty(addr) || strcmp(addr,'') || hex2dec(addr) > hex2dec('00FF') || size(addr,2) < 4 || size(addr,2) > 4
                    fprintf('Error: Enter Right Read Address first!\n');
                else
                    newLine = char([13 10]);
                    writeline(obj.virtualObject, [addr ' 0' newLine]);
%                     disp([addr ' 0' newLine])
                    line = readline(obj.virtualObject);
                    received_data = char(line);
                    received_data = received_data(6:end-1);
                    if isequal(currentRow.Type,'HEX')
                        q = quantizer('mode','fixed','format',[number_of_bits_in_num 0]);
                        received_data_bin = hex2bin(q,received_data);
                        %y = bin2dec(received_data_bin);
                        currentRow.Data = dec2hex(bin2dec(received_data_bin));
                    elseif isequal(currentRow.Type,'FLO')
                        q = quantizer('mode','float','roundmode','round','format',...
                            [number_of_bits_in_num 8]); %всегда ли тут 8?
%                         disp(received_data)
                        received_data_bin = hex2bin(q,received_data);
%                         disp(received_data_bin)
                        currentRow.Data = bin2num(q,received_data_bin);
%                         disp(currentRow.Data)
                        currentRow.Data = num2str(currentRow.Data);
                    elseif isequal(currentRow.Type,'DFL')
                        q = quantizer('mode','double','roundmode','round','format',...
                            [number_of_bits_in_num 0]);
                        %disp(q)
                        received_data_bin = hex2bin(q,received_data);
                        disp(received_data_bin)
                        currentRow.Data = bin2num(q,received_data_bin);
                        disp(currentRow.Data)
                        currentRow.Data = num2str(currentRow.Data);
                        %disp('Error: type DFL is not ready yet');
                    elseif isequal(currentRow.Type,'USG')
                        %y = bin2dec(x_bin) %%
                        q = quantizer('mode','ufixed','format',[number_of_bits_in_num 0]);
                        received_data_bin = hex2bin(q,received_data);
                        currentRow.Data = bin2num(q,received_data_bin);
                        currentRow.Data = num2str(currentRow.Data);
                    elseif isequal(currentRow.Type,'SIG')
                        q = quantizer('mode','fixed','format',[number_of_bits_in_num 0]);
                        received_data_bin = hex2bin(q,received_data);
                        currentRow.Data = bin2num(q,received_data_bin);
                        currentRow.Data = num2str(currentRow.Data);
                    else
                        disp('Error: there is no such type');
                    end
                    obj.lastRead = currentRow.Data;
                end
            else
                error('wrong type');
            end
        end
        % Запись данных по названию ячейки
        function obj = writeDataToFPGA(obj,name,wvalue) %wvalue - строка
            wvalueinit = wvalue;
            type = whatType(obj,name);
            
            if ~isequal(type,'NaT')
                currentRow = obj.addressTable(name,:);
                number_of_bits_in_num = str2double(currentRow.Number_of_bits{1,1});
                waddr = currentRow.Address{1,1};
                waddr(1) = '4';
                % Преобразование значения
                if isequal(currentRow.Type,'HEX')
                    wvalue = char(wvalue);
                elseif isequal(currentRow.Type,'FLO')
                    q = quantizer('mode','float','roundmode','round','format',...
                            [number_of_bits_in_num 8]); %всегда ли тут 8?
                        %num2bin(q,wvalue);
                        wvalue = str2double(wvalue);
                        wvalue = num2hex(q,wvalue);
%                         disp(wvalue)
                elseif isequal(currentRow.Type,'DFL')
                    disp('Error: type DFL is not ready yet');
                elseif isequal(currentRow.Type,'USG') || isequal(currentRow.Type,'SIG')
                    wvalue = str2double(wvalue);
                    wvalue = dec2hex(wvalue,16);
                else
                    disp('Error: there is no such type');
                end
                currentRow.Data = wvalue;
                newLine = char([13 10]);
                writeline(obj.virtualObject,[waddr ' ' wvalue newLine]);
%                 disp([waddr ' ' wvalue newLine])
            else
                error('wrong type')
            end
            obj = readDataFromFPGA(obj,name);
%             disp('last read')
%             disp(obj.lastRead)
%             disp('init')
%             disp(wvalueinit)
            try
                %переписать эту часть
                a = str2double(obj.lastRead);
                b = str2double(wvalueinit);
%                 disp(a)
%                 disp(b)
                if isequal(currentRow.Type,'FLO') && a ~= b
                    str = ['Значение' wvalueinit ' не записалось'];
                    error(str);
                elseif (isequal(currentRow.Type,'HEX') || isequal(currentRow.Type,'USG') || isequal(currentRow.Type,'SIG')) && ~isequal(obj.lastRead,wvalueinit)
                    str = ['Значение' wvalueinit ' не записалось'];
                    error(str);
                end

            catch ME
                fig = uifigure;
                uialert(fig,ME.message,'Failed');
            end
        end
        % Запись данных по названию ячейки в EEPROM
        function obj = writeDataToFPGAeeprom(obj,name,wvalue) %wvalue - строка
            wvalueinit = wvalue;
            type = whatType(obj,name);
            if ~isequal(type,'NaT')
                currentRow = obj.addressTable(name,:);
                waddr = currentRow.Address{1,1};
                waddr(1) = '6';
                % Преобразование значения
                if isequal(currentRow.Type,'HEX')
                    wvalue = char(wvalue);
%                     disp(wvalue)
                elseif isequal(currentRow.Type,'FLO')
                    q = quantizer('mode','float','roundmode','round','format',...
                            [number_of_bits_in_num 8]); %всегда ли тут 8?
                        %num2bin(q,wvalue);
                        wvalue = str2double(wvalue);
                        wvalue = num2hex(q,wvalue);
%                         disp(wvalue)
                elseif isequal(currentRow.Type,'DFL')
                    disp('Error: type DFL is not ready yet');
                elseif isequal(currentRow.Type,'USG') || isequal(currentRow.Type,'SIG')
                    wvalue = str2double(wvalue);
                    wvalue = dec2hex(wvalue,16);
                else
                    disp('Error: there is no such type');
                end
                currentRow.Data = wvalue;
                newLine = char([13 10]);
%                 disp([waddr ' ' wvalue newLine])
                writeline(obj.virtualObject,[waddr ' ' wvalue newLine]);
            else
                error('wrong type')
            end
            obj = readDataFromFPGAeeprom(obj,name);
%             disp('last read')
%             disp(obj.lastRead)
%             disp('init')
%             disp(wvalueinit)
            try
                if ~isequal(obj.lastRead,wvalueinit)
                    error(['Значение' wvalueinit ' не записалось']);
                end
            catch ME
                fig = uifigure;
                uialert(fig,ME.message,'Failed');
            end
        end
        % Чтение данных по названию ячейки из eeprom
        function obj = readDataFromFPGAeeprom(obj,name)
            type = whatType(obj,name);
            if ~isequal(type,'NaT')
                currentRow = obj.addressTable(name,:);
                number_of_bits_in_num = str2double(currentRow.Number_of_bits{1,1});
                addr = currentRow.Address{1,1};
                addr(1) = '2';
%                 if isempty(addr) || strcmp(addr,'') || hex2dec(addr) > hex2dec('00FF') || size(addr,2) < 4 || size(addr,2) > 4
%                     fprintf('Error: Enter Right Read Address first!\n');
%                 else
                    newLine = char([13 10]);
                    writeline(obj.virtualObject, [addr ' 0' newLine]);
                    line = readline(obj.virtualObject);
                    received_data = char(line);
                    received_data = received_data(6:end-1);
                    if isequal(currentRow.Type,'HEX')
                        q = quantizer('mode','fixed','format',[number_of_bits_in_num 0]);
                        received_data_bin = hex2bin(q,received_data);
                        %y = bin2dec(received_data_bin);
                        currentRow.Data = dec2hex(bin2dec(received_data_bin));
                    elseif isequal(currentRow.Type,'FLO')
                        q = quantizer('mode','float','roundmode','round','format',...
                            [number_of_bits_in_num 8]); %всегда ли тут 8?
                        received_data_bin = hex2bin(q,received_data);
                        currentRow.Data = bin2num(q,received_data_bin);
                        currentRow.Data = num2str(currentRow.Data);
                    elseif isequal(currentRow.Type,'DFL')
                        q = quantizer('mode','double','roundmode','round','format',...
                            [number_of_bits_in_num 0]);
                        disp(q)
                        received_data_bin = hex2bin(q,received_data);
                        disp(received_data_bin)
                        currentRow.Data = bin2num(q,received_data_bin);
                        disp(currentRow.Data)
                        currentRow.Data = num2str(currentRow.Data);
                        %disp('Error: type DFL is not ready yet');
                    elseif isequal(currentRow.Type,'USG')
                        %y = bin2dec(x_bin) %%
                        q = quantizer('mode','ufixed','format',[number_of_bits_in_num 0]);
                        received_data_bin = hex2bin(q,received_data);
                        currentRow.Data = bin2num(q,received_data_bin);
                        currentRow.Data = num2str(currentRow.Data);
                    elseif isequal(currentRow.Type,'SIG')
                        q = quantizer('mode','fixed','format',[number_of_bits_in_num 0]);
                        received_data_bin = hex2bin(q,received_data);
                        currentRow.Data = bin2num(q,received_data_bin);
                        currentRow.Data = num2str(currentRow.Data);
                    else
                        disp('Error: there is no such type');
                    end
                    obj.lastRead = currentRow.Data;
                %end
            else
                error('wrong type');
            end
        end
        % Вывод типа представления данных
        function output = whatType(obj,name)
            %проверка что такое имя существует
            if ismember({name},obj.addressTable.Row)
                currentRow = obj.addressTable(name,:);
                output = currentRow.Type{1};
            else
                output = 'NaT';
            end
        end
        % Проверка, что существует указанное имя
        % Можно добавить, что введенное значение не выпадает из диапазона
        %         function logicOutput = isNameExist(obj,name)
        %             if ismember({name},obj.addressTable.Row)
        %                 logicOutput = true;
        %             else
        %                 logicOutput = false;
        %             end
        %         end
        
        
        %         % Проверка подключения
        %         function output = isConnected(obj)
        %             name = obj.addressTable.Row{1};
        %             obj = readDataFromFPGA(obj,name);
        %
        %         end
        % Закрытие соединения
        function obj = enableBERT(obj,number)
            % number = 1,2,...
            numberStr = num2str(number);
            BERT_EN_name = ['BERT_EN_' numberStr];
            obj = writeDataToFPGA(obj,BERT_EN_name,'1');
        end
        function obj = disableBERT(obj,number)
            % number = 1,2,...
            numberStr = num2str(number);
            BERT_EN_name = ['BERT_EN_' numberStr];
            obj = writeDataToFPGA(obj,BERT_EN_name,'0');
        end
        function result = checkForLink(obj,number)
            % Значение number = 1, 2, 3 или 4
            number = num2str(number);
            
            BERT_LOCKED_name = ['BERT_LOCKED_' number];
            obj = readDataFromFPGA(obj,BERT_LOCKED_name);
            result = str2double(obj.lastRead); % 1 или 0
        end
        function result = checkBERT(obj,number)
            % Значение number = 1, 2, 3 или 4
            number = num2str(number);
            
            BERT_EN_name = ['BERT_EN_' number];
            obj = readDataFromFPGA(obj,BERT_EN_name);
            BERT_EN = str2double(obj.lastRead);
            if BERT_EN == 0
                error('BERT disable');
            end
            
            % Чтение этого параметра обновляет проверку
            BERT_UPDATE_name = ['BERT_UPDATE_' number];
            obj = readDataFromFPGA(obj,BERT_UPDATE_name);
            %BERT_UPDATE = str2double(obj.lastRead);
            
            BERT_RX_DATA_name = ['BERT_RX_DATA_' number];
            obj = readDataFromFPGA(obj,BERT_RX_DATA_name);
            BERT_RX_DATA = str2double(obj.lastRead);
            
            BERT_RX_ERR_name = ['BERT_RX_ERR_' number];
            obj = readDataFromFPGA(obj,BERT_RX_ERR_name);
            BERT_RX_ERR = str2double(obj.lastRead);
            
            BERT_LOCKED_name = ['BERT_LOCKED_' number];
            obj = readDataFromFPGA(obj,BERT_LOCKED_name);
            BERT_LOCKED = str2double(obj.lastRead);
            
            BERT_BER = BERT_RX_ERR / BERT_RX_DATA;
            
            result = struct('BERT_EN',BERT_EN,...
                'BERT_RX_DATA',BERT_RX_DATA,...
                'BERT_RX_ERR',BERT_RX_ERR,...
                'BERT_BER',BERT_BER,...
                'BERT_LOCKED',BERT_LOCKED);
            % к структуре можно обращаться result.BERT_EN и тд
        end
        function obj = turnOnOffDiodes(obj,state)
            % state = 'on', 'off'
            name = 'LDD_EN';
            if isequal(state,'on')
                wvalue = 'F';
            elseif isequal(state,'off')
                wvalue = '0';
            end
            obj = writeDataToFPGA(obj,name,wvalue);
        end
        function obj = setValueToLddCurrent(obj,LDnumber,valueNum)
            %LDnumber - num, valueNum - num
            number = num2str(LDnumber);
            fpgaName = ['LDD' number '_CURRENT'];
            wvalue = num2str(valueNum);
            obj = writeDataToFPGA(obj,fpgaName,wvalue);
        end
        function obj = deleteVirtualObject(obj)
            %if ~isequal(class(obj.virtualObject),'double')
            flush(obj.virtualObject);
            delete(obj.virtualObject);
            %end
        end
    end
end