% Повторение одной функции для всех элементов массива
function new_arr = repeatFunc(arr,func)

n = length(arr);
for i = 1:n
    new_arr(i,:) = func(arr(i));
end

end