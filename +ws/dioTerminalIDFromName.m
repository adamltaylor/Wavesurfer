function result = dioTerminalIDFromName(name)
    isDigit = isstrprop(name, 'digit') ;
    result = str2double(name(isDigit)) ;
end
