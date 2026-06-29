function MakingElements_Skript
fid = fopen('Pes.txt');
for i = 1:111
    line = fscanf(fid,'%c',57);
    fseek(fid,2,'cof');
    fid1 = fopen(['D:\Dienst\SAWXD\Data\MSK-Files (Mathematica)\','my-',strtrim(line(1,13:14)),'.msk']);
    if fid1 ~= -1
        fclose(fid1);
        obj = Sample.ChemicalElement();
        obj.Name = strtrim(line(1,13:14));
        obj.FullName = strtrim(line(1,1:12));
        obj.AtomicNumber = str2double(line(1,17:19));
        obj.AtomicMass = str2double(line(1,21:27));
        if ~isnan(str2double(line(1,29:35))/1000)
            obj.MassDensity = str2double(line(1,29:35))/1000;
        else
            continue;
            fclose(fid);
        end
        obj.MAC_Data = Sample.ChemicalElement.MskToMAC_OLD(['my-' obj.Name]);
        obj.SaveToFile(obj.Name);
    end
end
fclose(fid);
end