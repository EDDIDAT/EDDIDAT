% Korrigiert das Spektrum gegen das Wigglerspektrum.
% Input: none
% Output: obj, korrigiertes Objekt, Measurement
function obj = CorrectWigglerSpectrum(obj,Mode)
    %Die Intensitäten werden durch den Wert der Wigglerfunktion von ihrer
    %Energie geteilt
    obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2) ./ ...
        Tools.Science.Physics.WigglerFunction(obj.EDSpectrum(:,1), Mode);
end