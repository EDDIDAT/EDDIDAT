classdef Utils
%% (* Utils *)
% Hier werden (statische) Methoden zur Verfuegung gestellt, die beim Umgang
% mit Java in Matlab helfen sollen.
% -------------------------------------------------------------------------
	
	methods (Static = true, Access = public)
		
		function ja = createJavaArray(mla, javaClass, asVector)
		% Erstellt aus einem Matlab-Array "mla" ein Java-Array der Klasse
		% "javaClass" mit der gleichen Dimension. Ist "asVector" auf
		% "true", wird es in ein eindimensionales Array konvertiert.
		
			if nargin == 2
				
				asVector = false;
			end
		
			validateattributes(javaClass, {'char'}, {'nonempty', 'row'});
			validateattributes(asVector, {'logical'}, {'scalar'});
			
			if (isempty(mla) && ~asVector)
				
				ja = java.lang.reflect.Array.newInstance(java.lang.Class.forName(javaClass), int32([1 0]));
				return;
			end
			
			s = size(mla);

			% Diese Methode braucht man, um beispielsweise leere Arrays zu erzeugen
			ja = java.lang.reflect.Array.newInstance(java.lang.Class.forName(javaClass), int32(s));

			% Werte Kopieren
			for i = 1:prod(s)

				% Indizes konvertieren
				ind = cell(length(s),1);
				[ind{:}] = ind2sub(s, i);
				ja(ind{:}) = javaObject(javaClass, mla(i));
			end
			
			% Vektor?
			if (asVector)
				
				ja = ja(:);
			end
		end
		
		function mla = createMatlabArray(ja)
		% Konvertiert ein Java-Array (beliebiger Dimension) in ein
		% Matlab-Array. Bis jetzt keine Validationspruefung!
			
			mla = cell2mat(cell(ja));
		end
	end
end

