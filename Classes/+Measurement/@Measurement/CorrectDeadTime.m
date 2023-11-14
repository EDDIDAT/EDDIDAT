% Korrigiert das Spektrum gegen die totzeitbedingte
% Linienlagenverschiebung.
% Input: none
% Output: obj, korrigiertes Objekt, Measurement
function obj = CorrectDeadTime(obj)

%% (* Übergabe der relevanten Eigenschaften *)
    t = obj.DeadTime;
    
%% (* Korrektur *)
    %Absolute Verschiebung des Spektrum um den Wert der Totzeit-Funktion
    obj.EDSpectrum(:,1) = obj.EDSpectrum(:,1) - ...
        obj.Diffractometer.Detector.DTLineRefraction(t);
end