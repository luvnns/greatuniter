function resultTable = createAddressTable(filename) %'ADDRESS.txt';
% Создание таблицы из txt файла
%filename = 'ADDRESS.txt'
fileID = fopen(filename,'r+');
reading_txt = fscanf(fileID,'%c');
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
resultTable = table(address_cell_Address,address_cell_Number_of_bits,address_cell_Type,address_Data,...
    'RowNames',address_cell_Name',...
    'VariableNames',{'Address','Number_of_bits','Type','Data'});
fclose(fileID);
end