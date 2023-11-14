%% (* REGIONEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse modelliert eine eindimensionale logische Region, d. h. einen
% Vektor bei dem eine 1 f�r eine Region steht und eine 0 keine Region ist.
%--------------------------------------------------------------------------
classdef LogicalRegions
    
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
    %% (* Charakterisierende Eigenschaften *)
    % Aus Performance-Gr�nden wir als charakteristische Eigenschaft nicht
    % eine logische Region genommen, sondern ein Array mit den Grenzen und
    % die L�nge des logischen Vektors
        %Die erste Zeile enth�lt die linken Kanten-Indizies, die zweite
        %Zeile die Rechten, double|va
        Limits = [];
        %L�nge des Regionen-Vektors, double|va
        Length = [];
    end
    
    %--> Abh�ngige Eigenschaften
    properties (Dependent = true)
        %Der eigentliche Regionenvektor, beim Setzen wird er in die obigen
        %Eigenschaften konvertiert, beim Abrufen werden die obigen Werte in
        %ein logischen Vektor verwandelt, logical|va
        Regions
    end
    
    %--> Setter und Getter
    methods
        function obj = set.Limits(obj,in)
            validateattributes(in,{'double'},...
                {'integer','positive','finite','size',[2 NaN]});
            %--> Linke Kanten m�ssen gr��er als die Rechten sein
            if all(in(1,:) <= in(2,:))
                obj.Limits = in;
                %--> �berpr�fung der L�nge in Bezug auf die Kanten
                if isempty(obj.Length)
                    obj.Length = in(2,end);
                elseif obj.Length < in(2,end)
                    obj.Length = in(2,end);
                end
            end
        end
        function obj = set.Length(obj,in)
            validateattributes(in,{'double'},...
                {'integer','positive','scalar'});
            obj.Length = in;
            %--> �berpr�fung der L�nge in Bezug auf die Kanten
            if isempty(obj.Limits)
                obj.Limits = [1; in];
            elseif (in < obj.Limits(2,end)) && (~isempty(obj.Limits))
                obj.Regions = obj.Regions(1:in);
            end
        end
    end
    
    %--> Setter und Getter f�r abh�ngige Eigenschaften
    methods
        function rtn = get.Regions(obj)
            
        %% (* Regionen erzeugen *)
            %Prealloc
            rtn(1:obj.Length) = false;
            %--> Regionen eintragen
            for i_c = 1:size(obj.Limits,2)
                rtn(obj.Limits(1,i_c):obj.Limits(2,i_c)) = true;
            end
        end
        function obj = set.Regions(obj,in)
            validateattributes(in,{'logical'},{'vector'});
            
        %% (* Kanten ermitteln *)
            %--> Falls es die Regionen bis zu den R�ndern gehen
            if in(1), FirstRegion_Left = 0; else FirstRegion_Left = []; end
            if in(end), LastRegion_Right = length(in);
            else LastRegion_Right = []; end
            %Kanten werden mit diff sichtbar
            Limits_tmp = reshape([FirstRegion_Left; find(diff(in(:)));...
                LastRegion_Right],2,[]);
            %Linke Kante ist Beginn der Region, vorher war der Index neben
            %der linken Kante markiert
            Limits_tmp(1,:) = Limits_tmp(1,:) + 1;
            %Eigenschaften zuweisen
            obj.Limits = Limits_tmp;
            obj.Length = length(in);
        end
    end
    
%% (* Methoden *)
    %--> �ffentliche Methoden
    methods (Access = public)
        %Vergr��erung bzw. Verkleinerung der Regionen
        obj = Enlarge(obj,Factor)
    end

%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsm�glichkeiten:
        % 1) Kein Argument
        % 2) Eingabe eines logischen Vektors
        % 3) Eingabe von Kanten und L�nge des Vektors
        function obj = LogicalRegions(varargin)
            %--> �berpr�fung der Anzahl der Eingabeargumente
            if nargin == 1
                obj.Regions = varargin{1};
            elseif nargin == 2
                obj.Limits = varargin{1};
                obj.Length = varargin{2};
            end
        end
    end
end