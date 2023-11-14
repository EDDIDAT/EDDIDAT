% Korrigiert das Spektrum gegen den Ringstrom.
% Input: RingCurrentNorm, Wert auf den der Ringstrom normiert wird, mA,
%         double|va
% Output: obj, korrigiertes Objekt, Measurement
function obj = CorrectRingCurrent(obj,RingCurrentNorm)

%% (* Stringenzprüfung *)
    validateattributes(RingCurrentNorm,{'double'},...
        {'real','scalar','positive','finite'})

%% (* Übergabe der relevanten Eigenschaften *)
    INorm = RingCurrentNorm;
    I = obj.RingCurrent;
    t = obj.DeadTime;
    
%% (* Korrektur *)
    %Relative Korrektur, in dem auf INorm normiert wird
    obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2) * ...
        (INorm / I) * (100 / (100 - t));
%     (INorm / (I * 100 / (100 - t))); %alt
end