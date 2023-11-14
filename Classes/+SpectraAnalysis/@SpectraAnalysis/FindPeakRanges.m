% Diese Funktion findet automatisch die Regionen, in denen in allen
% Spektrem Peaks vorhanden sind. Dabei werden kleine Intervalle um die
% Peaks erstellt und anschlie�end der Schnitt �ber alle Spektren erstellt.
% Die Ausgabe der PeakRegionen kann dann schlie�lich in
% CreateFromPeakRanges eingesetzt werden.
% Input: DL_Unfiltered, Ungefilterte Peaks (au�en Zelle = Messungen), 
%         (innen DiffractionLine = Peaks pro Messung),
%         cell|DiffractionLine|va /
%        RangeWidth, Vorgabeintervallbreite, double|va
% Output: PeakRanges, Intervalle in denen in allen Messungen Peaks sind,
%          double|[2 NaN]
function PeakRanges = FindPeakRanges(DL_Unfiltered,RangeWidth)

%% (* Stringenzpr�fung *)
    validateattributes(DL_Unfiltered,{'cell'},{'vector'});
    validateattributes(RangeWidth,{'double'},...
        {'finite','real','nonnegative'})
    
%% (* Intervalle bilden und Schnitt erzeugen *)
    %Prealloc (skalar)
    PeakRanges = true;
    %Da der DB �ber alle Messungen der gleiche ist, gen�gt es einen
    %Repr�sentativen zu nehmen
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
        %Den n�chstgelegensten Index der Intervallr�nder im DB finden
        EnergyRange(1,:)= Tools.Data.DataSetOperations.FindNearestIndex(...
            EDSpectrum_tmp,EnergyRange(1,:));
        EnergyRange(2,:)= Tools.Data.DataSetOperations.FindNearestIndex(...
            EDSpectrum_tmp,EnergyRange(2,:));
        %Logische Regionen erzeugen
        EnergyRange = Tools.LogicalRegions(...
            EnergyRange,length(EDSpectrum_tmp));
        %�berschneidung mit den �brigen Bereichen durchf�hren
        PeakRanges = PeakRanges & EnergyRange.Regions;
    end
    %Intervallr�nder als Indizies
    PeakRanges = Tools.LogicalRegions(PeakRanges);
    %Davon die Werte aus dem DB
    PeakRanges = num2cell(EDSpectrum_tmp(PeakRanges.Limits));
end