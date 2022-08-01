function str = num2strForPrint(value)
if isequal(class(value),'double')
    num = value;
    format shortg
    num = round(num,2);
    str = num2str(num);
else
    str = value;
end
end