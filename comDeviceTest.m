clear
clc
% Вводные параметры
comPort = 'COM37';
baudRate = 115200;
filename = 'comDevice';
fileformat = 'xlsx';
% Создание подключения
device = comDevice(comPort,baudRate,filename,fileformat);
% Цикл считывания данных
for i = 1:100
    device = readData(device);
end
% Вычисление среднего значения в мс
calcMeanMS(device)
% Закрытие COM-порта
device = deleteVirtualObject(device);