% Diese Funktion erstellt aus den komplett gefitteten Spektren ein
% Auswertungsobjekt. Dabei werden alle Peaks über alle Messungen (Anzahl
% der Peaks kann variieren) übergeben, sowie festgelegte Bereiche, in denen
% nach Auswertungs-Peaks gesucht wird. Dabei können die Bereichsgrenzen,
% sogar Funktionen in Abhängigkeit von der Messungsnummer sein.
% Abkürzungen: DL = DiffractionLines
% Input: DL_Unfiltered, Ungefilterte Peaks (außen Zelle = Messungen), 
%         (innen DiffractionLine = Peaks pro Messung),
%         cell|DiffractionLine|va / 
%        PeakRanges, Bereiche in denen nach passenden Peaks gesucht werden
%         soll, ist der Eingabewert ein double, so wird der Wert in eine
%         konstante Funktion umgewandelt, cell|double|function_handles|va
% Output: obj, Auswertungs-Objekt, SpectraAnalysis|scalar
function obj = CreateFromDL(DL_Unfiltered,PeakRanges)

%% (* Stringenzprüfung *)
    validateattributes(DL_Unfiltered,{'cell'},{'vector'});
    validateattributes(PeakRanges,{'cell'},{'size',[2 NaN]});
    
%% (* Vorbereitung *)
    %Prealloc
    obj = SpectraAnalysis.SpectraAnalysis();
    obj.DiffractionLines = repmat(SpectraAnalysis.DiffractionLine,...
        [length(DL_Unfiltered),size(PeakRanges,2)]);
    %--> Doubles in konstante Funktionen verwandeln
    for i_c = 1:size(PeakRanges,2)
        %--> Linke Grenzen
        if isa(PeakRanges{1,i_c},'double')
            PeakRanges{1,i_c} = str2func(['@(m)',...
                num2str(PeakRanges{1,i_c})]);
        end
        %--> Rechte Grenzen
        if isa(PeakRanges{2,i_c},'double')
            PeakRanges{2,i_c} = str2func(['@(m)',...
                num2str(PeakRanges{2,i_c})]);
        end
    end

%% (* Suchroutine ausführen *)
    %--> Durchlaufen aller Messungen
    for i_c = 1:length(DL_Unfiltered)
        %Grenzen ermitteln für die konkrete Messung ausrechnen
        PeakRanges_tmp = cellfun(@(x)feval(x,i_c),PeakRanges);
        %Energie-Positionen der Peaks der aktuellen Messung
        if (isscalar(get(DL_Unfiltered{i_c},'Energy_Max')))
            Energy_tmp = get(DL_Unfiltered{i_c},'Energy_Max');
        else
            Energy_tmp = cell2mat(get(DL_Unfiltered{i_c},'Energy_Max'));
        end
        %--> Es wird geschaut, ob es Peaks in den Intervallen gibt
        for j_c = 1:size(PeakRanges_tmp,2)
            %Aktuelles Intervall
            EnergyRange = PeakRanges_tmp(1:2,j_c);
            %Finden von Peaks in diesem Intervall (der erste wird
            %genommen), dabei wird die linke und die rechte Grenze von den
            %Energie-Positionen abgezogen, und eine Überschneidung von
            %negativen Werten bedeutet, dass der Index ein Peak im
            %Intervall ist
            Peak_Matching = find(((EnergyRange(1) - Energy_tmp) <= 0)...
                & ((Energy_tmp - EnergyRange(2)) <= 0),1);
            %--> Wenn ein Peak gefunden wurde, wird dieser eingetragen
            if ~isempty(Peak_Matching)
                obj.DiffractionLines(i_c,j_c) = ...
                    DL_Unfiltered{i_c}(Peak_Matching);
            %--> Wenn nicht, dann wird ein "Null-Peak" erzeugt, d. h. er
            %    hat die Intensität NaN
            else
                obj.DiffractionLines(i_c,j_c) = ...
                    SpectraAnalysis.DiffractionLine();
                obj.DiffractionLines(i_c,j_c).Measurement = ...
                    DL_Unfiltered{1}(1).Measurement;
                obj.DiffractionLines(i_c,j_c).Intensity_Max = 0;
                obj.DiffractionLines(i_c,j_c).Energy_Max = ...
                    EnergyRange(1) + abs(diff(EnergyRange) / 2);
            end
            %Passende Indizies zuweisen
            obj.DiffractionLines(i_c,j_c).LineNumber = [i_c,j_c];
        end %--> for j_c = 1:size(PeakRanges_tmp,2)
    end %--> for i_c = 1:length(DL_Unfiltered)
end

