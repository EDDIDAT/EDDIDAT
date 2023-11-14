% Diese Funktion findet automatisch die Regionen, in denen in allen
% Spektrem Peaks vorhanden sind. Dabei werden kleine Intervalle um die
% Peaks erstellt und anschließend der Schnitt über alle Spektren erstellt.
% Die Ausgabe der PeakRegionen kann dann schließlich in
% CreateFromPeakRanges eingesetzt werden.
% Input: DL_Unfiltered, Ungefilterte Peaks (außen Zelle = Messungen), 
%         (innen DiffractionLine = Peaks pro Messung),
%         cell|DiffractionLine|va /
%        RangeWidth, Vorgabeintervallbreite, double|va
% Output: PeakRanges, Intervalle in denen in allen Messungen Peaks sind,
%          double|[2 NaN]
function PeakRanges = FindPeakRanges(DL_Unfiltered,RangeWidth)

%% (* Stringenzprüfung *)
    validateattributes(DL_Unfiltered,{'cell'},{'vector'});
    validateattributes(RangeWidth,{'double'},...
        {'finite','real','nonnegative'})
    
%% (* Intervalle bilden und Schnitt erzeugen *)
    %Prealloc (skalar)
    PeakRanges = true;
    %Da der DB über alle Messungen der gleiche ist, genügt es einen
    %Repräsentativen zu nehmen
    EDSpectrum_tmp = DL_Unfiltered{1}(1).Measurement.EDSpectrum(:,1);
    %--> Durchlaufen aller Messungen
    for i_c = 1:length(DL_Unfiltered)
        %Energiepositionen der Peaks auslesen
        if (isscalar(get(DL_Unfiltered{i_c},'Energy_Max')))
            EnergyPositions = get(DL_Unfiltered{i_c},'Energy_Max');
        else
            EnergyPositions = cell2mat(get(DL_Unfiltered{i_c},'Energy_Max'));
        end
        %Bereiche ermitteln
        EnergyRange = [EnergyPositions' - RangeWidth;...
            EnergyPositions' + RangeWidth];
        %Den nächstgelegensten Index der Intervallränder im DB finden
        EnergyRange(1,:)= Tools.Data.DataSetOperations.FindNearestIndex(...
            EDSpectrum_tmp,EnergyRange(1,:));
        EnergyRange(2,:)= Tools.Data.DataSetOperations.FindNearestIndex(...
            EDSpectrum_tmp,EnergyRange(2,:));
        %Logische Regionen erzeugen
        EnergyRange = Tools.LogicalRegions(...
            EnergyRange,length(EDSpectrum_tmp));
        %Überschneidung mit den übrigen Bereichen durchführen
        PeakRanges = PeakRanges & EnergyRange.Regions;
    end
    %Intervallränder als Indizies
    PeakRanges = Tools.LogicalRegions(PeakRanges);
    %Davon die Werte aus dem DB
    PeakRanges = num2cell(EDSpectrum_tmp(PeakRanges.Limits));
end