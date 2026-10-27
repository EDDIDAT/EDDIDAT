# CIF to MPD

Kleine GUI zum Erzeugen von EDDIDAT-Materialdateien (`.mpd`) aus CIF-Dateien, mit Spektrumsimulation.

## Start

```
pip install -r requirements.txt
python cif_to_mpd_gui.py [datei.cif]
```

Eine einzelne `CIF_to_MPD.exe` erzeugt `build_exe.bat` (PyInstaller, Ergebnis in `dist\`).

## Bedienung

0. **COD-Suche** (Reiter „Source“): Formel (`SiC`, `Al2O3`, `Fe3O4`) oder Name (`quartz`, `moissanite`) eingeben und **Search** drücken. Eine Formel wird in die COD-Schreibweise umgewandelt (`SiC` → `C Si`), alles andere als Textsuche (Name, Mineral, Titel) gesendet. Die Treffer (COD-Nummer, Formel, Name, Raumgruppe, Zelle, Jahr; Spaltenköpfe sortieren) zeigen unter der Liste Titel, Zeitschrift sowie Temperatur und Druck der Messung. **Load selected CIF** (oder Doppelklick) lädt `https://www.crystallography.net/cod/<ID>.cif` in `%USERPROFILE%\.cif_to_mpd\cache`, liest die Datei ein und berechnet die Parameter. Der Dateiname wird als `<Name>_COD<ID>` vorgeschlagen. Zum COD werden nur der Suchbegriff und die COD-Nummer gesendet.
1. **Open CIF...** wählt eine lokale Datei, **Calculate parameters** füllt die Felder.
2. **Parameters** (editierbar): Dateiname, Elemente, Stöchiometrie, Ordnungszahlen, Atomgewichte, Dichte, Gittertyp (immer `none`), Gitterparameter in nm. Darunter stehen Raumgruppe und Zelle zur Kontrolle. Die Dichte wird aus Zelle und Inhalt berechnet (Besetzungen werden berücksichtigt).
3. **Reflections**: berechnet alle symmetrie-unabhängigen Reflexe mit d (nm), Multiplizität und relativer Intensität I = m·|F|² (|F| aus Atomlagen, Streufaktoren und optional Debye-Waller-Faktoren der CIF). Reflexe unter der Schwelle „min. I (%)“ werden nicht angezeigt. Ein Doppelklick schließt einzelne Reflexe aus oder wieder ein.
4. **Export .mpd...** schreibt die Datei im Format von `Data\Materials`.
5. **Spektrum**:
   - *Energy-dispersive*: Linien bei E = hc / (2 d sin θ) für festes 2θ.
   - *Angle-dispersive*: Linien bei 2θ für eine Wellenlänge (Ag, Mo, Cu, Co, Fe, Cr Kα1), optional mit Lorentz-Polarisationsfaktor.
   - Optional gaußverbreiterte Kurve und hkl-Beschriftung.

## Hinweise und Grenzen

- Die Intensitäten sind kinematisch (m·|F|²) ohne Quellenspektrum, Detektoreffizienz, Absorption, Textur und ohne Fluoreszenzlinien. Für energiedispersive Spektren sind sie daher nur ein Anhaltspunkt für die Intensitätsverhältnisse.
- Anomale Streuung (f′, f″) wird nicht berücksichtigt.
- Das `.mpd`-Format speichert nur einstellige Indizes. Reflexe mit Index ≥ 10 werden beim Export weggelassen (die Anzahl wird angezeigt).
- Die hkl-Schreibweise ist ein symmetrieäquivalenter Vertreter der Familie (z. B. `101` statt `011`). Die d-Werte sind davon nicht betroffen.
- Monokline und trikline Zellen: Die Winkel lassen sich im Format nicht speichern. Es wird ein Hinweis angezeigt.
- CIF-Dateien ohne Raumgruppe (P1) werden verarbeitet. Das Kristallsystem wird dann aus den Zellparametern abgeleitet, gleichwertige Reflexe werden anhand von d und |F|² zusammengefasst.
- Einstellungen (letzte Ordner) stehen in `%USERPROFILE%\.cif_to_mpd.json`.

## COD-Anbindung: Hinweise

- Benötigt eine Internetverbindung (HTTPS, Port 443). In Firmennetzen kann ein Proxy die Anfrage blockieren.
- Der COD-Server bricht Verbindungen gelegentlich ab. Das Programm wiederholt eine Anfrage bis zu siebenmal. Bei einer Fehlermeldung hilft meist ein erneutes Suchen.
- Es gibt oft mehrere Einträge zur selben Verbindung (verschiedene Autoren, Temperaturen, Drücke, Polytypen). Für 6H-SiC etwa steht „Moissanite 6H“. Die Einträge mit modernem Jahr, Raumtemperatur und vollständiger Struktur sind meist am besten. Die Zelle in der Tabelle hilft bei der Auswahl.
- Zu allgemeine Suchen werden abgebrochen („Antwort zu groß“). Dann genauer suchen (z. B. Formel statt Elementname).

## Dateien

| Datei | Inhalt |
|---|---|
| `cif_to_mpd_gui.py` | GUI (tkinter, matplotlib) |
| `cif_mpd_core.py` | Rechenkern (gemmi, numpy) |
| `cod_search.py` | Suche und Download in der Crystallography Open Database |
| `build_exe.bat` | Paketierung mit PyInstaller |
| `requirements.txt` | benötigte Pakete |
| `..\cif_zu_mpd.py` | ältere Kommandozeilenversion (pymatgen) |
