filename = 'mpd-File-Dummy.txt';
fid = fopen(filename, 'wt');
if fid ~= -1 
  fprintf(fid, 'Dateiname: ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'Elementliste: ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'Stoechiometrieliste: ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'Ordnungszahlliste: ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'Atomgewichtsliste (in g/mol): ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'Materialdichte (in g/cm^3): ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'Gittertyp: ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'Gitterparameter (in nm): ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');
  fprintf(fid, 'hkl- und d-Wertliste: ');
  fprintf(fid, '\n');
  fprintf(fid, '\n');

  fclose(fid);
end