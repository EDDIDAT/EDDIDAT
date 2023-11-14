% Load transfer data file
M = Tools.StringOperations.AsciiFile2Text('d:\Profile\hrp\Eigene Dateien\Privat\Comunio_Transfer_Data1.txt','\r\n');
% Load Teams
Teams = {'BSG Chemie Alt-Karow';'Vorwaerts Ostheim';'Lokomotive Ostblock';'VEB Schuhkombinat';'SV Aufbau Ueckeritz';'Maueropfer 88';'Dynamo Sergej';'FDGB Motor Moesi';'Kombinat Berlin-Ost';'CSKA Union Baron';'SV Schabowski';'Volkswerft Peenedribbel Malekin'};
Teams1 = {'BSG Chemie Alt-Karow','Vorwärts Ostheim','Lokomotive Ostblock','VEB Schuhkombinat','SV Aufbau Ückeritz','Maueropfer 88','Dynamo Sergej','FDGB Motor Mösi','Kombinat Berlin-Ost','CSKA Union Baron','SV Schabowski','Volkswerft Peenedribbel Malekin'};
% Load transfer Zu- bzw. Abgänge
for k = 1:size(Teams,1)
    Index_Scan_Zu{k} = Tools.StringOperations.SearchString(M,['zu ',Teams{k}]);
end

for k = 1:size(Teams,1)
    Index_Scan_Von{k} = Tools.StringOperations.SearchString(M,['von ',Teams{k}]);
end

for k = 1:size(Index_Scan_Zu,2)
    if ~isempty(Index_Scan_Zu{k})
        
        for m = 1:size(Index_Scan_Zu{k},1)
%             tmp = regexp(M(Index_Scan_Zu{k}(m),:),'\d{6,}','Match');
            Ausgaben{k}(m,:) = str2double(regexp(M(Index_Scan_Zu{k}(m),:),'\d{6,}','Match'));
        end
    else
        Ausgaben{k} = [];
    end  
end

Ausgaben_Final = cellfun(@sum,Ausgaben);

for k = 1:size(Index_Scan_Von,2)
    if ~isempty(Index_Scan_Von{k})
        
        for m = 1:size(Index_Scan_Von{k},1)
%             tmp = regexp(M(Index_Scan_Von{k}(m),:),'\d{6,}','Match');
            Einnahmen{k}(m,:) = str2double(regexp(M(Index_Scan_Von{k}(m),:),'\d{6,}','Match'));
        end
    else
        Einnahmen{k} = [];
    end  
end

Einnahmen_Final = cellfun(@sum,Einnahmen);
% Startbonus
Bonus = [20500000;20100000;22500000;21000000;20100000;20100000;20250000;20250000;20250000;20500000;20250000;20100000];

% Create table
Table = table([Teams1'],[Bonus],[Einnahmen_Final'],[Ausgaben_Final'],[Bonus+Einnahmen_Final'-Ausgaben_Final']);
Table.Properties.VariableNames = {'Team','Startbonus','Einnahmen','Ausgaben','Kontostand'};

Table_sort = sortrows(Table,'Kontostand','descend');