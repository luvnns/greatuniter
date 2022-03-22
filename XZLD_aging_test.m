clc;
clear;
close all;
%%
% В начале работы проверьте соответствие 
% COM-портов и интерфейс подключения
number_com_1 = 'COM11'; %ИОМ 1 - 
number_com_2 = 'COM12'; %ИОМ 2 -
number_com_3 = 'COM19'; %ИОМ 3 - Мощность трансивера Teradian
number_com_4 = 'COM15'; %ИОМ 4 - Мощность, поступающая на трансивер rad
number_com_5 = 'COM16'; %ИОС ист - мощность источника РУБИН
number_com_6 = 'COM17'; %ИОМ атт - прошедшая мощность через аттенюатор


visa_adr = 'USB0::0x1313::0x8072::1911793::INSTR'; %thorlabs power meter
visa_adr2 = 'USB::0x0AAD::0x0197::3638.3376k03-100829::INSTR'; %rohde-schwarz power source

%%

% Введите количество измерений
N = 672;

% Введите количество секунд между измерениями
s = 30*60;

% Создание названия файла (в названии указывается время последнего измерения)
real_date_and_time1 = datestr(now,'yyyymmddhhMMss');
filename_txt = char(strcat('Checking_EOC_teradian_',real_date_and_time1,'.txt'));
filename_mat = char(strcat('Checking_EOC_teradian_',real_date_and_time1,'.mat'));

%% Подключаем BERT
% Скорость
SPEED = 1.25e8;

bert_log = 0;

% подключаемся к BERT 
t   = vinit('JTAG'); % или RS
q24 = quantizer([24 0]);  % https://www.mathworks.com/help/fixedpoint/ref/bin2num.html

load('bert_measure_address_struct.mat');
for fn = fieldnames(ADDRESS)'
    all_data_read.(fn{1}) = ADDRESS.(fn{1});
end
%%

pm = visa('ni',visa_adr);

%% Подключаем измеритель Thorlabs и настраиваем
fopen(pm);

fprintf(pm, 'CONFigure:POWer'); %настройка измеряемой величины

text_1 = 'SENSe:CORRection:WAVelength';
text_2 = '976';
operation_wave = strcat(text_1,32,text_2);
fprintf(pm, operation_wave);
%fprintf(pm, 'SENSe:CORRection:WAVelength?');%запрос оперируемой длины волны
%out = fscanf(pm);

% установка единиц измерения
units = 'W'; %'DBM';
text_1 = 'SENSe:POWer:UNIT';
text_2 = units;
out = strcat(text_1,32,text_2);
fprintf(pm, out); %установка единиц измерения
%fprintf(pm, 'SENSe:POWer:UNIT?');
%out = fscanf(pm);

% установка усреднения
text_1 = 'SENSe:AVERage:COUNt';
text_2 = '1';
out = strcat(text_1,32,text_2);
fprintf(pm, out); %усреднение 
%fprintf(pm, 'SENSe:AVERage:COUNt?');
%out = fscanf(pm);

% установка аттенюации
text_1 = 'SENSe:CORRection:LOSS';
loss = '0';
text_2 = loss;
out = strcat(text_1,32,text_2);
fprintf(pm, out); %установка аттенюации в дБ
%fprintf(pm, 'SENSe:CORRection:LOSS?');
%out = fscanf(pm);

% спектральный фильтр
text_1 = 'INPut:PDIode:FILTer:LPASs:STATe';
text_2 = num2str('OFF');
out = strcat(text_1,32,text_2);
fprintf(pm, out);%выключить спектральный фильтр (10Hz) to (100kHz)
%fprintf(pm, 'INPut:PDIode:FILTer:LPASs:STATe?');
%out = fscanf(pm);

% Установка диапазона измерения
out = 'CURRent:RANGe:AUTO ON';
fprintf(pm, out);

fclose(pm); 

%% Читаем
i = 1;
 while i<=N

    clc;
    fprintf('Iteration number, cycles elapsed: %d\n',i);
    
    %  bert 0
%     read_data_from_FPGA(t,all_data_read.BERT_UPDATE_0); % bit
%     BERT_EN_0             = read_data_from_FPGA(t,all_data_read.BERT_EN_0); % bit
%     BERT_RX_DATA_MON_0    = hex2num((read_data_from_FPGA(t,all_data_read.BERT_RX_DATA_MON_0))'); % double
%     BERT_ERR_MON_0        = hex2num((read_data_from_FPGA(t,all_data_read.BERT_ERR_MON_0))'); % double
%     BERT_LOCKED_0         = read_data_from_FPGA(t,all_data_read.BERT_LOCKED_0); % bit
%     
%     BERT_BER_0        = BERT_ERR_MON_0 / BERT_RX_DATA_MON_0;
%     
%     BERT_EN_bin_0         = dec2bin(hex2dec(BERT_EN_0(end:end))); % bit
%     BERT_LOCKED_bin_0     = dec2bin(hex2dec(BERT_LOCKED_0(end:end))); % bit
%     
%     BERT_EN_0        = str2double(BERT_EN_bin_0(end));  % bit
%     BERT_LOCKED_0    = str2double(BERT_LOCKED_bin_0(end));  % bit
%     
    %  bert 1
    read_data_from_FPGA(t,all_data_read.BERT_UPDATE_1); % bit
    BERT_EN_1             = read_data_from_FPGA(t,all_data_read.BERT_EN_1); % bit
    BERT_RX_DATA_MON_1    = hex2num((read_data_from_FPGA(t,all_data_read.BERT_RX_DATA_MON_1))'); % double
    BERT_ERR_MON_1        = hex2num((read_data_from_FPGA(t,all_data_read.BERT_ERR_MON_1))'); % double
    BERT_LOCKED_1         = read_data_from_FPGA(t,all_data_read.BERT_LOCKED_1); % bit
    
    BERT_BER_1        = BERT_ERR_MON_1 / BERT_RX_DATA_MON_1;
    
    BERT_EN_bin_1         = dec2bin(hex2dec(BERT_EN_1(end:end))); % bit
    BERT_LOCKED_bin_1     = dec2bin(hex2dec(BERT_LOCKED_1(end:end))); % bit
    
    BERT_EN_1        = str2double(BERT_EN_bin_1(end));  % bit
    BERT_LOCKED_1    = str2double(BERT_LOCKED_bin_1(end));  % bit
    
    
    % Получение значений с ИОМ
    OPM_1 = 0;
    OPM_2 = 0;
    OPM_3 = 0;
    OPM_4 = 0;
    OPM_5 = 0;
    OPM_6 = 0;
    OPM_LD = 0;
    
    % Получение значений с ИОМ
    OPM_1 = read_power_from_rubin(number_com_1,'dBm');
    OPM_2 = read_power_from_rubin(number_com_2,'dBm');
    OPM_3 = read_power_from_rubin(number_com_3,'dBm');
    OPM_4 = read_power_from_rubin(number_com_4,'dBm');
    OPM_5 = read_power_from_rubin(number_com_5,'dBm');
    OPM_6 = read_power_from_rubin(number_com_6,'dBm');
    
    %thorlabs
    fopen(pm);
    %fprintf(pm, '*CLS');
    fprintf(pm, 'INITiate');
    fprintf(pm, 'MEASure:POWer');
    fprintf(pm, 'READ?');
    out = fscanf(pm);
    OPM_LD = str2num(out);
    pause(1);
    fclose(pm); 
    
%     Источник Rodhe&Swartz
%     ps = visa('ni',visa_adr2);
%     fopen(ps);
% 
%     fprintf(ps, '*CLS'); % Очистка буфера
%     Измерение канала №1 - Лазерный диод
%     query_volt = 'MEAS:VOLT? (@1)';
%     fprintf(ps, query_volt);
%     VOLT = fscanf(ps);
%     volt_value1 = str2num(VOLT);
%     query_curr = 'MEAS:CURR? (@1)';
%     fprintf(ps, query_curr);
%     CURR = fscanf(ps);
%     curr_value1 = str2num(CURR);
%     Измерение канала №2 - Фотодиод Laserscom
%     query_volt = 'MEAS:VOLT? (@2)';
%     fprintf(ps, query_volt);
%     VOLT = fscanf(ps);
%     volt_value2 = str2num(VOLT);
%     query_curr = 'MEAS:CURR? (@2)';
%     fprintf(ps, query_curr);
%     CURR = fscanf(ps);
%     curr_value2 = str2num(CURR);
% 
%     fclose(ps); 
%     delete(ps);
%     clear ps;
    
    % Если R&S заболел
    volt_value1 = 0;
    curr_value1 = 0;
    volt_value2 = 0;
    curr_value2 = 0;



    % Время и дата
    real_date_and_time = datestr(now,'yyyymmddhhMMss');
    real_date = real_date_and_time(1:8);
    real_time = real_date_and_time(9:14);
    
    real_time_hour = str2double(real_time(1:2));
    real_time_minute = str2double(real_time(3:4));
    real_time_second = str2double(real_time(5:6));
    
    real_time_in_seconds = (real_time_hour*60 + real_time_minute)*60 + real_time_second;
    double_real_date_and_time = str2double(real_date_and_time);
    
    % Сбор всех данных

% %         Если ПЛИС отключили
        BERT_EN_0 = 0;
        BERT_RX_DATA_MON_0 = 0;
        BERT_ERR_MON_0 = 0;
        BERT_BER_0 = BERT_ERR_MON_0/BERT_RX_DATA_MON_0;
        BERT_LOCKED_0 = 0;

%         BERT_EN_1 = 0;
%         BERT_RX_DATA_MON_1 = 0;
%         BERT_ERR_MON_1 = 0;
%         BERT_BER_1 = BERT_ERR_MON_1/BERT_RX_DATA_MON_1;
%         BERT_LOCKED_1 = 0;    

        data = [BERT_EN_0,...
        BERT_RX_DATA_MON_0,...
        BERT_ERR_MON_0,...
        BERT_BER_0,...
        BERT_LOCKED_0,...
        BERT_EN_1,...
        BERT_RX_DATA_MON_1,...
        BERT_ERR_MON_1,...
        BERT_BER_1,...
        BERT_LOCKED_1,...
        OPM_1,...
        OPM_2,...
        OPM_3,...
        OPM_4,...
        OPM_5,...
        OPM_6,...
        OPM_LD,...
        volt_value1,...
        curr_value1,...
        volt_value2,...
        curr_value2,...
        real_time_in_seconds,...
        double_real_date_and_time];
    

    received_data_all(i,:) = data;
    
    %вывод измеренных значений мощности в консоль
    fprintf('\nBER_0: %d\n', BERT_BER_0);
    fprintf('BER_1: %d\n', BERT_BER_1);
    fprintf('Опт. мощность ЛДН, мВт: %4.2f\n', OPM_LD*1000);
    fprintf('Напряжение ЛДН, В: %4.4f\n', volt_value1);
    fprintf('Ток накачки ЛДН, А: %4.4f\n', curr_value1);
    fprintf('Ток ФД, мА: %4.4f\n', curr_value2*1000);
    fprintf('Опт. мощность ИОМ1, дБм: %4.2f\n', OPM_1);
    fprintf('Опт. мощность ИОМ2, дБм: %4.2f\n', OPM_2);
    fprintf('Опт. мощность ИОМ3, дБм: %4.2f\n', OPM_3);
    fprintf('Опт. мощность ИОМ4, дБм: %4.2f\n', OPM_4);
    fprintf('Опт. мощность ИОМ атт, дБм: %4.2f\n', OPM_5);
    fprintf('Опт. мощность ИОМ ист, дБм: %4.2f\n', OPM_6);

    
    
    %% Сохранение массива received_data_all в txt файл



% Открываем txt файл
fid = fopen(filename_txt,'a');

number_of_columns = length(data);

% Cоздаем формат для сохранения данных
string_for_saving = '';
for j = 1:number_of_columns
    string_for_saving = strcat(string_for_saving,'%d;');
end
string_for_saving = strcat(string_for_saving(1:end-1),'\n');

% Записываем данные в txt файл
fprintf(fid,string_for_saving,data);
    
fclose(fid);


%% Cохранение массива received_data_all из workspace в файл mat
%filename = char(strcat('Checking_LD_',real_date_and_time1,'.mat'));
save(filename_mat,'received_data_all'); 


    % Пауза с учетом примерного времени выполнения программы
    pause(s);
    i = i+1;
    
 end