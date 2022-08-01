function filename = createFilename(datetime,name)
% filename = name_dateTtime
% date in format yyyymmdd
% time in format HHMMSS
% Function may accept only datetime
% Or none inputs (then datetime = now)
if nargin == 0
    name = '';
    datetime = now;
elseif nargin == 1
    name = '';
% elseif nargin == 2
%     name = [name,'_'];
end
date = datestr(datetime, 'yyyymmdd');
time = datestr(datetime, 'HHMMSS');
filename = [name,date,'T',time];
end