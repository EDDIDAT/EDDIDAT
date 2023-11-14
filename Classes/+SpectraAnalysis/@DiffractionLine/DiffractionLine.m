%% (* BEUGUNGSREFLEX-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse repräsentiert einen ausgewerteten Beugungsreflex, der später
% einen Teil eines Auswertungsobjektes darstellt. Dabei wird vor allem das
% Messobjekt als Referenz übergeben, damit man auf alle wichtigen Daten,
% die zu dem Peak gehören zugreifen kann.
%--------------------------------------------------------------------------
classdef DiffractionLine < General.MLRObject

%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        
    %% (* Allgemeines und Herkunft des Peaks *)
        %Zum Peak gehöriges Messobjekt, Measurement|va
        Measurement = [];
        %Identifizierungs-Variable für einen Peak [Nummer der Messung,
        %Nummer des Peaks in einem Spektrum], 0 = keine Vorgabe, double|va
        LineNumber = [0 0];
        %HKL-Werte des Reflexes [h k l], bei keiner Vorgabe [0 0 0], 
        %no unit, double|va
        HKL = [0 0 0];
        
    %% (* Peak-Eigenschaften *)
    % Alle Eigenschaften, die den Peak direkt charakterisieren, Prop_Delta
    % entspricht dem Fehler dieser Eigenschaft
        %Energieposition mit der maximalen Intensität E_Max, keV, double|va
        Energy_Max = 0;
        Energy_Max_Delta = 0;
        %Die zugehörige Intensität zum Energiemaximum I_Max, falls der Peak
        %"virtuell" ist, so kann man hier 0 angeben, cts, double|va
        Intensity_Max = 0;
        Intensity_Max_Delta = 0;
        Intensity_Int_calc = 0;
        %Integrale Breite beta, keV, double|va
        IntegralWidth = 0;
        IntegralWidth_Delta = 0;
        %Breite auf halber Höhe 2omega, keV, double|va
        FWHM = 0;
        FWHM_Delta = 0;
        % Gauss und Lorentz-Anteil an der FWHM (nur bie TCH Funktion)
        FWHM_Gauss = 0;
        FWHM_Lorentz = 0;
        %Gewichtsfaktor (wird benutzt, wenn man Kombinationen von
        %Fitfunktionen verwendet, z. B. Pseudo Voigt), no unit, double|va
        WeightingFactor = 0;
        %Netzebenenabstand d, lässt man den Wert auf 0, so wird der Wert
        %aus 2theta und der Energie-Position berechnet, nm, double|va
        LatticeSpacing = 0;
        LatticeSpacing_Delta = 0;
    end
    
    %--> Abhängige Eigenschaften
    properties (Dependent = true)
        
    %% (* Peak-Eigenschaften *)
    % DeltaProp entspricht dem Fehler dieser Eigenschaft
        %Peak-Integral, keV*cts, double|scalar
        Intensity_Int
        Intensity_Int_Delta
        %Form-Faktor 2omega/beta, keV, double|scalar
        FormFactor    
    end
    
    %--> Setter und Getter
    methods
        function set.Measurement(obj,in)
            validateattributes(in,{'Measurement.Measurement'},...
                {'scalar'});
            obj.Measurement = in;
        end
        function set.LineNumber(obj,in)
            validateattributes(in,{'double'},...
                {'integer','size',[1 2],'nonnegative'});
            obj.LineNumber = in;
        end
        function set.HKL(obj,in)
            validateattributes(in,{'double'},...
                {'integer','size',[1 3]});
            obj.HKL = in;
        end
        function set.Energy_Max(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.Energy_Max = in;
        end
        function set.Energy_Max_Delta(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.Energy_Max_Delta = in;
        end
        function set.Intensity_Max(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar'});
            obj.Intensity_Max = in;
        end
        function set.Intensity_Max_Delta(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.Intensity_Max_Delta = in;
        end
        function set.Intensity_Int_calc(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar'});
            obj.Intensity_Int_calc = in;
        end
        function set.IntegralWidth(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.IntegralWidth = in;
        end
        function set.IntegralWidth_Delta(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.IntegralWidth_Delta = in;
        end
        function set.FWHM(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.FWHM = in;
        end
        function set.FWHM_Delta(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.FWHM_Delta = in;
        end
        function set.FWHM_Gauss(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.FWHM_Gauss = in;
        end
        function set.FWHM_Lorentz(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.FWHM_Lorentz = in;
        end
        function set.WeightingFactor(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar'});
            obj.WeightingFactor = in;
        end
        function set.LatticeSpacing(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','nonnegative'});
            obj.LatticeSpacing = in;
        end
%         function set.twotheta(obj,in)
%             validateattributes(in,{'double'},...
%                 {'real','scalar','nonnegative'});
%             obj.twotheta = in;
%         end
        function rtn = get.LatticeSpacing(obj)
            %--> Falls man keine explizite Vorgabe gemacht hat
            if obj.LatticeSpacing == 0
                if strcmp(obj.Measurement.Diffractometer.Name,'ETA3000')
                    % Lambda noch als Parameter aus Measurement einfuegen
                    rtn = 0.178897./(2*sind(obj.Energy_Max/2));
                else
                    rtn = 0.6199./sind(obj.twotheta ./ 2)./ ...
                    obj.Energy_Max;
                end
%                 rtn = Tools.Science.Physics.BraggEq_E(...
%                     1,obj.twotheta ./ 2,obj.Energy_Max,[]);
            else
                rtn = obj.LatticeSpacing;
            end
        end
        function set.LatticeSpacing_Delta(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','nonnegative'});
            obj.LatticeSpacing_Delta = in;
        end
        function rtn = get.LatticeSpacing_Delta(obj)
            %--> Falls man keine explizite Vorgabe gemacht hat
            if obj.LatticeSpacing_Delta == 0
                if strcmp(obj.Measurement.Diffractometer.Name,'ETA3000')
                    rtn = 0.178897./(4.*cosd(obj.Energy_Max/2)./...
                        sind(obj.Energy_Max/2).^2).*obj.Energy_Max_Delta;
                else
                    if obj.Energy_Max_Delta == 0
                        % If fitting produces zero error Energy_Max_Delta, set
                        % it to 0.01 in order to be able to fit the sin²Psi
                        % data
                        rtn = ((0.6199./sind(obj.twotheta ./ 2))./ ...
                        obj.Energy_Max.^2) .* 0.01;
                    else
                        rtn = ((0.6199./sind(obj.twotheta ./ 2))./ ...
                        obj.Energy_Max.^2) .* obj.Energy_Max_Delta;
                    end
                end
            else
                rtn = obj.LatticeSpacing_Delta;
            end
        end
    end
    
    %--> Getter für abhängige Eigenschaften
    methods
        
    %% (* Peak-Eigenschaften *)
        function rtn = get.Intensity_Int(obj)
            rtn = obj.Intensity_Max * obj.IntegralWidth;
        end
        function rtn = get.FormFactor(obj)
            rtn = obj.FWHM ./ obj.IntegralWidth;
        end
    end
    
%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        %Erzeugen eines Peak-Objektes aus den Fitparametern einer
        %Gauss-Funktion
        obj = CreateFromFitParam_Gauss(FitParam,CI,Measurement_in)
        %Lorentz-Funktion
        obj = CreateFromFitParam_Lorentz(FitParam,CI,Measurement_in)
        %Pseudo-Voigt-Funktion
        obj = CreateFromFitParam_PV(FitParam,CI,Measurement_in)
        %TCH Funktion
        obj = CreateFromFitParam_TCH(FitParam,CI,Measurement_in)
    end
    
%% (* Sonstige Eigenschaften *)

    %% (* Abkürzungen für Eigenschaften der Messung *)
    % Diese Eigenschaften werden ledliglich eingeführt, um den Zugriff auf
    % wichtige Eigenschaften der Messung zu erleichtern. Beschreibungen der
    % Eigenschaften befinden sich im Objekt Measurement
    properties (Dependent = true)
        Sample
        Time
        RealTime
        DeadTime
        RingCurrent
        SampleStagePos
        SCSAngles
        twotheta
        Motors % neu 14.10.2016
    end
    
    %--> Getter
    methods
        function rtn = get.Sample(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.Sample;
            else
                rtn = [];
            end
        end
        function rtn = get.Time(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.Time;
            else
                rtn = [];
            end
        end
        function rtn = get.RealTime(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.RealTime;
            else
                rtn = [];
            end
        end
        function rtn = get.DeadTime(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.DeadTime;
            else
                rtn = [];
            end
        end
        function rtn = get.RingCurrent(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.RingCurrent;
            else
                rtn = [];
            end
        end
        function rtn = get.SampleStagePos(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.SampleStagePos;
            else
                rtn = [];
            end
        end
        function rtn = get.SCSAngles(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.SCSAngles;
            else
                rtn = [];
            end
        end
        function rtn = get.twotheta(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.twotheta;
            else
                rtn = [];
            end
        end
        function rtn = get.Motors(obj)
            if ~isempty(obj.Measurement)
                rtn = obj.Measurement.Motors;
            else
                rtn = [];
            end
        end
    end
    
%% (* Objektversion *)
    properties (Hidden = true, SetAccess = private, GetAccess = private)
         %Objektversion, string
         ObjectVersion = '1.0.0';
    end
    
    %--> Abrufmethode der Eigenschaft
    methods (Hidden = true, Access = public)
        % Gibt die Versionsnummer des Objektes wieder.
        % Input: none
        % Output: rtn, Objektversion, string
        function rtn = Version(obj), rtn = obj.ObjectVersion; end
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsmöglichkeiten:
        % 1) Kein Argument
        % 2) Eingabe von Eigenschaften per InputParser
        function obj = DiffractionLine(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Zum Finden der relevanten Linienlagen auch hkl-Linien der JCPDF-DB
%   benutzen