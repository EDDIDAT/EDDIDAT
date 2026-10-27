@echo off
rem Erzeugt CIF_to_MPD.exe (eine einzelne Datei) im Unterordner dist.
rem Voraussetzung: pip install -r requirements.txt
cd /d "%~dp0"
rem Qt-Bindings und grosse, nicht benoetigte Pakete ausschliessen (sonst bricht PyInstaller bei mehreren Qt-Paketen ab)
python -m PyInstaller --noconfirm --onefile --windowed --name CIF_to_MPD ^
  --exclude-module PyQt5 --exclude-module PyQt6 --exclude-module PySide2 --exclude-module PySide6 ^
  --exclude-module IPython --exclude-module pandas --exclude-module scipy --exclude-module pytest --exclude-module sphinx ^
  cif_to_mpd_gui.py
echo.
echo Fertig: %~dp0dist\CIF_to_MPD.exe
pause
