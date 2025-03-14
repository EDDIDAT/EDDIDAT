% Diese Methode exportiert das Auswertungs-Objekt als PSI-File, um damit in
% Mathematica weiterarbeiten zu k�nnen
% Input: Filename, Dateiname (ohne Endung), string|va /
% Output: none
function SaveToPsiFileNew(DiffractionLines,Filename,FileName,FitFunc,SpecFileCheck)

%% (* Stringenzpr�fung *)
    validateattributes(Filename,{'char'},{'row'});

%% (* Vorbereitung *)
    %Pfad bilden
    Path = Filename;
    %Datei erzeugen
    fid = fopen(Path,'w');
    %DL als Vektor (Abk�rzung)
    DL = DiffractionLines;
    %Measurement mode
    assignin('base','DiffractionLines',DL)

if FitFunc == 2 || FitFunc == 4 || FitFunc == 5
   %PV-Func        %Gauss          %Lorentz
%% (* Kopf hinzuf�gen *)
    if SpecFileCheck == 1
        %Datei-Name
        fprintf(fid,'Dateiname: %s.\n\n',FileName);
        %Spalten
        fprintf(fid,['LNr     ',...
            'Emax   ',...
            'dEmax    ',...
            'Iint      ',...
            'Ib      ',...
            'tth     ',...
            'phiP   ',...
            'psiP   ',...
            'etaP  ',...
            'xdiff   ',...
            'ydiff   ',...
            'zdiff   ',...
            'RT  ',...
            'DT   ',...
            'temp1   ',...
            'temp2   ',...
            'heatrate    ',...
            'time','\n\n']);
    else
        %Datei-Name
        fprintf(fid,'Dateiname: %s.\n\n',FileName);
        %Spalten
        fprintf(fid,['LNr     ',...
            'Emax   ',...
            'dEmax    ',...
            'Iint      ',...
            'Ib      ',...
            'tth     ',...
            'phiP   ',...
            'psiP   ',...
            'etaP  ',...
            'xdiff   ',...
            'ydiff   ',...
            'zdiff   '...
            '\n\n']);
    end
%% (* Daten eintragen *)
    %--> Durchlaufen aller Peaks
    for i_c = 1:size(DL,1)
        % Peak-Infos
        if SpecFileCheck == 1
            fprintf(fid,'  %d.  %.3f  %.4f  %d  %.4f  %.2f  %.2f  %.2f  %.3f  %.4f  %.4f  %.4f  %.2f  %.2f  %.1f  %.1f  %.2f  %s\n',...
                DL(i_c,1:17),datestr(DL(i_c,18),'dd-mm-yyyy-HH-MM-SS'));
        else
            fprintf(fid,'  %d.  %.3f  %.4f  %d  %.4f  %.2f  %.2f  %.2f  %.3f  %.4f  %.4f  %.4f\n',...
                DL(i_c,1:12));
        end
    end
elseif FitFunc == 3 %TCH-Func
%% (* Kopf hinzuf�gen *)
    if SpecFileCheck == 1
        %Datei-Name
        fprintf(fid,'Dateiname: %s.\n\n',FileName);
        %Spalten
        fprintf(fid,['LNr     ',...
            'Emax   ',...
            'dEmax    ',...
            'Iint      ',...
            'Ib      ',...
            'FWHM      ',...
            'FWHM_Gauss      ',...
            'FWHM_Lorentz      ',...
            'tth     ',...
            'phiP   ',...
            'psiP   ',...
            'etaP  ',...
            'xdiff   ',...
            'ydiff   ',...
            'zdiff   ',...
            'RT  ',...
            'DT   ',...
            'temp1   ',...
            'temp2   ',...
            'heatrate    ',...
            'time','\n\n']);
    else
        %Datei-Name
        fprintf(fid,'Dateiname: %s.\n\n',FileName);
        %Spalten
        fprintf(fid,['LNr     ',...
            'Emax   ',...
            'dEmax    ',...
            'Iint      ',...
            'Ib      ',...
            'FWHM      ',...
            'FWHM_Gauss      ',...
            'FWHM_Lorentz      ',...
            'tth     ',...
            'phiP   ',...
            'psiP   ',...
            'etaP  ',...
            'xdiff   ',...
            'ydiff   ',...
            'zdiff   ',...
            '\n\n']);
    end
    
%% (* Daten eintragen *)
    %--> Durchlaufen aller Peaks
    for i_c = 1:size(DL,1)
        if SpecFileCheck == 1
            % Peak-Infos
            fprintf(fid,'  %d.  %.3f  %.4f  %d  %.4f  %.4f  %.4f  %.2e  %.2f  %.2f  %.2f  %.2f  %.1f  %.2f  %.2f  %.4f  %.4f  %.4f  %.4f  %.4f  %.4f  %.1f  %.1f %.2f  %s\n',...
                DL(i_c,1:20),datestr(DL(i_c,21),'dd-mm-yyyy-HH-MM-SS'));
        else
            % Peak-Infos
            fprintf(fid,'  %d.  %.3f  %.4f  %d  %.4f  %.4f  %.4f  %.2e  %.2f  %.2f  %.2f  %.2f  %.1f  %.2f  %.2f  %.4f  %.4f  %.4f  %.4f\n',...
                DL(i_c,1:15));
        end
    end    
end
    %Datei schlie�en
    fclose(fid);
end