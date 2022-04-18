function newpath = selectTable(oldpath)
[file,path] = uigetfile('*.xlsx','Select table',oldpath);
output = [path file];
if isequal(file,0) || ~isfile(output)
    output = '';
end
newpath = output;
end