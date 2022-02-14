function filename = createFilename(name,datetime)
    % Запрос текущего времени
    %datetime = now;

    % Сохранение текущего времени в 2 переменные в нужном формате
    date = datestr(datetime, 'yyyymmdd');
    time = datestr(datetime, 'HHMMSS');
% 
%     % Сохранение текущего времени в 3 переменные
%     HH = str2double(time(1:2));
%     MM = str2double(time(3:4)); 
%     SS = str2double(time(5:6));
% 
%     % Время от начала дня в секундах
%     time_in_seconds = num2str((HH * 60 + MM) * 60 + SS);

    % Итоговое название файла
    filename = strcat(name,'_',date,'T',time);
%filename = strcat(name,'_',date,'T',time,'_',time_in_seconds);
end