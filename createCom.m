function results = createComs(coms_str,func)

coms_str = strsplit(coms_str);
n = length(coms_str);
for i = 1:n
    comPort = char(coms_str(i));
    results(i) = func(comPort);
end
end