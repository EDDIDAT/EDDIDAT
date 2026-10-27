# Vorschlag: Offline-Betrieb von CIF to MPD mit lokaler COD-Kopie

Stand: 26. Oktober 2026. Dies ist ein Vorschlag, noch nichts davon ist umgesetzt.

## 1. Ausgangslage

Die Anwendung CIF to MPD sucht CIF-Dateien bisher online in der Crystallography Open Database (COD) über deren Web-Schnittstelle (Formelsuche, Textsuche, Download der CIF). Das setzt eine Internetverbindung voraus, und der COD-Server bricht Verbindungen gelegentlich ab.

Gewünscht ist die Möglichkeit, auch offline zu arbeiten, zum Beispiel mit einer COD-Kopie auf einem Netzlaufwerk, auf das die Anwendung zugreift.

## 2. Die COD lokal beschaffen

Die COD erlaubt ausdrücklich den Download der gesamten Datenbank (Quelle: https://wiki.crystallography.net/howtoobtaincod/):

| Weg | Befehl oder Adresse | Hinweis |
|---|---|---|
| Subversion (SVN) | `svn co svn://www.crystallography.net/cod` | von der COD für die meisten Nutzer empfohlen, spätere Updates mit `svn update`, braucht mehr Platz (Versionsverlauf) |
| rsync | `rsync -av --delete rsync://www.crystallography.net/cif/ cif/` | nur aktueller Stand, einfachster Weg für den reinen CIF-Bestand, Update mit demselben Befehl |
| Archiv | `http://www.crystallography.net/archives/cod-cifs-mysql.zip` (auch `.tgz`, `.txz`) | nur als letzte Möglichkeit, wird nur alle drei bis vier Monate erneuert |
| Einzelabruf per HTTP | `http://www.crystallography.net/cif/` | nicht für den Gesamtbestand gedacht, die COD bittet um etwa zwölf Sekunden Pause zwischen den Anfragen |

**Größe:** Die COD-Seite nennt nur Zahlen von 2011 (CIF-Ordner etwa 5 GB, vollständiges SVN etwa 11 GB). Heute ist der Bestand deutlich größer, eine aktuelle Angabe fehlt. Den Platzbedarf vorher mit einem Probelauf abschätzen (`rsync -av --dry-run --stats ...`) und mehrere bis einige zehn Gigabyte einplanen.

**Unter Windows** sind rsync und SVN nicht vorinstalliert. Möglich sind WSL (Linux unter Windows), cwRsync oder TortoiseSVN.

Ein Teilbestand ist ebenfalls möglich (z. B. nur Strukturen mit bestimmten Elementen oder nur anorganische Verbindungen). Das spart Platz und Indexierungszeit.

## 3. Warum ein Index nötig ist

Die COD besteht aus einzelnen CIF-Dateien in einem Verzeichnisbaum (Muster `cif/1/00/00/1000017.cif`). Es gibt keine Suchfunktion. Online sucht der COD-Server in seinem eigenen Index. Lokal müsste das Programm für jede Suche mehrere hunderttausend Dateien über das Netz lesen, das wäre viel zu langsam.

## 4. Lösung: ein einmalig erzeugter Index

Ein Hilfsprogramm liest alle CIF-Dateien einmal ein und speichert aus jeder nur die für die Suche wichtigen Angaben in einer **SQLite-Datei** (eine einzelne Datei, SQLite ist in Python eingebaut):

| Feld | Quelle in der CIF |
|---|---|
| COD-Nummer | Dateiname |
| Formel | `_chemical_formula_sum` |
| Name, Mineral | `_chemical_name_mineral`, `_chemical_name_common`, `_chemical_name_systematic` |
| Raumgruppe | `_space_group_name_H-M_alt` |
| Zelle a, b, c, Winkel | `_cell_length_*`, `_cell_angle_*` |
| Jahr, Titel, Zeitschrift | `_journal_year`, `_publ_section_title`, `_journal_name_full` |
| Pfad | relativer Pfad zur Datei |

Ablauf:

1. Die Formel wird im Index in derselben Schreibweise abgelegt wie bei der Online-Suche (Hill-System, z. B. `C Si`). Dafür kann die vorhandene Funktion `formula_to_cod` im Modul `cod_search.py` weiterverwendet werden.
2. Die Suche in der GUI läuft dann im Index (Millisekunden). Die Trefferliste sieht aus wie bisher.
3. Beim Laden holt das Programm die CIF direkt aus dem Ordner. Berechnung, Reflexliste, Spektrum und Export bleiben unverändert.
4. Nach einem Update der Kopie wird nur für neue oder geänderte Dateien nachindexiert (Vergleich über Änderungsdatum).

## 5. Änderungen an der Anwendung

- Im Reiter "Source" kommt eine Auswahl **Database: Online (COD) / Local folder** hinzu.
- Ein Feld für den Pfad der lokalen Kopie (auch ein UNC-Pfad wie `\\server\cod`) und ein Knopf **Choose folder...**.
- Ein Knopf **Build / update index** mit Fortschrittsanzeige (nur für die Person, die die Kopie pflegt).
- Optional: Fällt der lokale Ordner aus oder liefert die Suche nichts, schaltet das Programm auf die Online-Suche um (mit Hinweis).
- Ein neues Modul (z. B. `cod_local.py`) mit Aufbau und Abfrage des Index. `cod_search.py` bleibt für die Online-Suche erhalten.
- Die Ordner- und Indexeinstellungen werden in `%USERPROFILE%\.cif_to_mpd.json` gespeichert.

## 6. Praktische Hinweise für das Netzlaufwerk

- **Eine Person pflegt, alle anderen lesen.** Die Kopie wird einmal heruntergeladen und indexiert, die übrigen Nutzer brauchen nur Leserechte. SQLite darf auf einem Netzlaufwerk nicht von mehreren Rechnern gleichzeitig beschrieben werden, nur gelesen.
- **Ablage:** Der Index liegt im selben Ordner wie die Kopie. Wenn die Suche über das Netz zäh ist, kann das Programm den Index beim ersten Start lokal zwischenspeichern.
- **Dauer der Erstindexierung:** Geschätzt etwa 15 bis 60 Minuten auf einer lokalen Platte, über das Netz deutlich länger. Das ist eine Schätzung, gemessen wurde es nicht.
- **Aktualisierung:** Die Kopie regelmäßig mit rsync oder `svn update` aktualisieren und danach den Index erneuern, zum Beispiel alle paar Monate.
- **Dateizugriff:** Es werden nur die Dateien gelesen, die der Nutzer lädt. Es entsteht kein Netzwerkverkehr zur COD.

## 7. Aufwand und Test

- Umsetzung: etwa ein halber Tag, Test eingeschlossen.
- Test mit einem kleinen Ausschnitt (einige hundert CIFs, die über die COD-Schnittstelle mit Pausen heruntergeladen werden). Der Praxistest mit der vollständigen Kopie und dem echten Netzlaufwerk muss auf dem Zielsystem erfolgen.
- Nach der Umsetzung: Anleitung (PDF) und Neubau der `CIF_to_MPD.exe`.

## 8. Offene Entscheidungen

1. **Umfang:** komplette COD oder eine Auswahl (bestimmte Elemente, nur anorganische Verbindungen)?
2. **Zielsystem:** nur Windows-Rechner? Hat jeder Leserechte auf dem Laufwerk? Wie lautet der Pfad (Laufwerksbuchstabe oder UNC)?
3. **Wer pflegt** die Kopie und den Index (und wie oft)?
4. **Rückfall:** soll das Programm bei einer nicht erreichbaren lokalen Kopie automatisch auf die Online-Suche umschalten?
5. **Index-Ablage:** direkt auf dem Netzlaufwerk oder zusätzlich lokal zwischengespeichert?

## 9. Alternativen mit weniger Aufwand

- **Nur Zwischenspeicher:** Die schon vorhandene Funktion speichert jede geladene CIF in `%USERPROFILE%\.cif_to_mpd\cache`. Wiederholt benötigte Strukturen sind damit offline verfügbar, die Suche geht dabei aber nicht.
- **Gemeinsamer Ordner mit häufig gebrauchten CIFs:** Eine kleine, von Hand gepflegte Sammlung (z. B. die in EDDIDAT benutzten Materialien) auf dem Netzlaufwerk. Das Programm öffnet sie wie eine lokale CIF-Datei (**Open CIF...**). Dafür ist keine Programmänderung nötig.
