classdef Device_FPGA
    properties (Constant)
        NEW_LINE = char([13,10])
        FLASH_MEM = 'FLASH'
        EEPROM_MEM = 'EEPROM'
    end
    properties (Constant)
        LDD_EN = 'LDD_EN'
        OSC_SFF_ENABLE = 'OSC_SFF_ENABLE'
        OSC_SFF_SD = 'OSC_SFF_SD'
    end
    properties
        virtualObject
        interface
        addressTable
        addressTablePath
        JTAGserverFolderPath
    end
    properties
        lastRead
        currentLinks %ex, = '0010' - link at 2nd transc (positions 4321)
    end
    methods
        function obj = Device_FPGA(appStruct)
            obj.interface = appStruct.InterfaceDropDown;
            obj.addressTablePath = appStruct.addressTablePath;
            obj.JTAGserverFolderPath = [pwd filesep];
            if obj.interface == "JTAG"
                try
                    obj.virtualObject =  tcpclient('localhost', 2540);
                catch
                    dos([obj.JTAGserverFolderPath 'run.bat&']);
                    obj.virtualObject =  tcpclient('localhost', 2540);
                end
            %elseif obj.interface == "?"
            end
            obj = readAddressTable(obj);
            obj = readData(obj,obj.FLASH_MEM,"CC_TEST");
        end
    
        function result = test(obj)
            obj = readData(obj,obj.FLASH_MEM,"CC_TEST");
            result = obj.lastRead;
        end
        function obj = readAddressTable(obj)
                % filename = 'ADDRESS.txt';
                fileID = fopen(obj.addressTablePath,'r+');
                reading_txt = fscanf(fileID,'%c');
                fclose(fileID);
                address_cell = regexp(reading_txt,'[^# ](\w{4}) = \[(\d*)\] = (\w*) = (\w*.\w*) =',...
                    'tokens');
                number_of_cell = length(address_cell);
                address_cell_Name = strings(number_of_cell,1);
                address_cell_Address = cell(number_of_cell,1);
                address_cell_Number_of_bits = cell(number_of_cell,1);
                address_cell_Type = strings(number_of_cell,1);
                address_Data = cell(number_of_cell,1);
                for i = 1:number_of_cell
                    address_cell_Name(i) = address_cell{1,i}{1,4};
                    address_cell_Address(i) = address_cell{1,i}(1);
                    address_cell_Number_of_bits(i) = address_cell{1,i}(2);
                    address_cell_Type(i) = address_cell{1,i}{1,3};
                end
                obj.addressTable = table(address_cell_Address,address_cell_Number_of_bits,address_cell_Type,address_Data,...
                    'RowNames',address_cell_Name',...
                    'VariableNames',{'ADDR','BITS','FRM','DATA'});
        end
        end
    methods
        function output = whatFRM(obj,name)
            if ismember({name},obj.addressTable.Row)
                currentRow = obj.addressTable(name,:);
                output = currentRow.FRM{1};
            else
                output = 'ERR';
            end
        end
        function obj = readData(obj,mem,name)
            currentRow = obj.addressTable(name,:);
            ADDR = currentRow.ADDR{1,1};
            if mem == obj.FLASH_MEM
                ADDR(1) = '0';
            elseif mem == obj.EEPROM_MEM
                ADDR(1) = '2';
            end
            BITS = str2double(currentRow.BITS{1,1});
            FRM = currentRow.FRM;
            writeline(obj.virtualObject, [ADDR ' ' '0' obj.NEW_LINE]);
            receivedDataStr = readline(obj.virtualObject);
            receivedDataChar = char(receivedDataStr);
            receivedData = receivedDataChar(6:end-1);
            if FRM == "HEX"
                q = quantizer('mode','fixed','format',[BITS 0]);
                receivedDataBin = hex2bin(q,receivedData);
                %y = bin2dec(received_data_bin);
                currentRow.Data = dec2hex(bin2dec(receivedDataBin));
            elseif FRM == "FLO"
                q = quantizer('mode','float','roundmode','round','format',...
                    [BITS 8]); %всегда ли тут 8?
                receivedDataBin = hex2bin(q,receivedData);
                receivedDataNum = bin2num(q,receivedDataBin);
                currentRow.Data = num2str(receivedDataNum);
            elseif FRM == "DFL"
                q = quantizer('mode','double','roundmode','round','format',...
                    [BITS 0]);
                receivedDataBin = hex2bin(q,receivedData);
                currentRow.Data = bin2num(q,receivedDataBin);
                currentRow.Data = num2str(currentRow.Data);
            elseif FRM == "USG"
                %y = bin2dec(x_bin) %%
                q = quantizer('mode','ufixed','format',[BITS 0]);
                receivedDataBin = hex2bin(q,receivedData);
                currentRow.Data = bin2num(q,receivedDataBin);
                currentRow.Data = num2str(currentRow.Data);
            elseif FRM == "SIG"
                q = quantizer('mode','fixed','format',[BITS 0]);
                receivedDataBin = hex2bin(q,receivedData);
                receivedDataNum = bin2num(q,receivedDataBin);
                currentRow.Data = num2str(receivedDataNum);
            end
            obj.lastRead = currentRow.Data;
        end
        function obj = writeData(obj,mem,name,data)
            % data format must be string
            currentRow = obj.addressTable(name,:);
            ADDR = currentRow.ADDR{1,1};
            if mem == obj.FLASH_MEM
                ADDR(1) = '4';
            elseif mem == obj.EEPROM_MEM
                ADDR(1) = '6';
            end
            BITS = str2double(currentRow.BITS{1,1});
            FRM = currentRow.FRM;
            if FRM == "HEX"
                sentData = char(data);
            elseif FRM == "FLO"
                wvalue = str2double(data);
                q = quantizer('mode','float','roundmode','round','format',...
                    [BITS 8]); %всегда ли тут 8?
                sentData = num2hex(q,wvalue);
            elseif FRM == "DFL"
                % not ready
            elseif FRM == "USG"
                wvalue = str2double(data);
                sentData = dec2hex(wvalue,16);
            elseif FRM == "SIG"
                wvalue = str2double(data);
                sentData = dec2hex(wvalue,16);
            end
            writeline(obj.virtualObject,[ADDR ' ' sentData obj.NEW_LINE]);
        end
        function obj = writeAndReadData(obj,mem,name,data)
            % data format must be string
            obj = writeData(obj,mem,name,data);
            obj = readData(obj,mem,name);
        end
        function hexStr = fourBitsToHex(binStr)
            bin = ['0b',binStr];
            dec = str2double(bin);
            hexStr = dec2hex(dec);
        end
        function binStr = hexToFourBits(hexStr)
            hex = ['0x',hexStr];
            dec = str2double(hex);
            binStr = dec2bin(dec,4);
        end
        function obj = setDiodesEn(obj,binInput) 
            % Ex: binInput = '0000' => turn off all diodes
            % Ex: binInput = '0010' => turn on only 2nd diode
            % diodes positions are 4321 in binInput
            data = fourBitsToHex(binInput);
            obj = writeAndReadData(obj,obj.FLASH_MEM,obj.LDD_EN,data);
        end
        function obj = setTransceiversEn(obj,binInput) 
            % Ex: binInput = '0000' => turn off all transceivers
            % Ex: binInput = '0010' => turn on only 2nd transceiver
            % transceivers positions are 4321 in binInput
            data = fourBitsToHex(binInput);
            obj = writeAndReadData(obj,obj.FLASH_MEM,obj.OSC_SFF_ENABLE,data);
        end
        function obj = checkLink(obj)
            obj = readData(obj,obj.FLASH_MEM,obj.OSC_SFF_SD);
            obj.currentLinks = hexToFourBits(obj.lastRead);
        end
        function obj = deleteVirtualObject(obj)
            %flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end