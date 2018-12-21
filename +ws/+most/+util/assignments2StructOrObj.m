function s = assignments2StructOrObj(str,s)
%ASSIGNMENTS2STRUCTOROBJ Create a struct, or configure a handle object,
%from a string generated by structOrObj2Assignments.
% s = assignments2Struct(str,s)
% 
% str: string generated by structOrObj2Assignments
% s [input]: (optional, scalar handle object). Object to configure.
% s [output]: If a handle object is supplied as s, that object is returned
% in s. If no object is supplied, a structure is created and returned in s.

if nargin < 2
    s = struct();
end

rows = textscan(str,'%s','Delimiter','\n');
rows = rows{1};

if isempty(rows)
    return;
end

for c = 1:numel(rows)
    row = rows{c};
    
    % replace top-level name with 'obj'
    [~, rmn] = strtok(row,'.');
    row = ['s' rmn];
    
    % deal with nonscalar nested structs/objs
    pat = '([\w]+)__([0123456789]+)\.';
    replc = '$1($2).';
    row = regexprep(row,pat,replc);
    
    % handle unencodeable value or nonscalar struct/obj.
    % Note: structOrObj2Assignments, assignments2StructOrObj, and toString
    % (all in ws.most.util) are in cahoots with respect
    % to these hardcoded strings.
    unencodeval = '<unencodeable value>';
    if strfind(row,unencodeval)
        row = strrep(row,unencodeval,'[]');
    end
    nonscalarstructobjstr = '<nonscalar struct/object>';
    if strfind(row,nonscalarstructobjstr)
        row = strrep(row,nonscalarstructobjstr,'[]');
    end
    
    % handle ND array format produced by array2Str
    try 
        if ~isempty(strfind(row,'&'))
            equalsIdx = strfind(row,'=');
            [dimArr rmn] = strtok(row(equalsIdx+1:end),'&');
            arr = strtok(rmn,'&');
            arr = reshape(str2num(arr),str2num(dimArr)); %#ok<NASGU,ST2NM>
            eval([row(1:equalsIdx+1) 'arr;']);
        else
            eval([row ';']);
        end
    catch ME %Warn if assignments to no-longer-extant properties are found
        if strcmpi(ME.identifier,'MATLAB:noPublicFieldForClass')
            equalsIdx = strfind(row,'=');
            fprintf(1,'WARNING: Property ''%s'' was specified, but does not exist for class ''%s''\n', deblank(row(3:equalsIdx-1)),class(s));
        else
            ME.rethrow();
        end
    end
end

end
