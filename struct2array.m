function a = struct2array(s)

c = struct2cell(s);

a = [c{:}];

end

