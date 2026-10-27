"""
cod_search.py  -  Suche in der Crystallography Open Database (COD, https://www.crystallography.net/cod/).

Nutzt die oeffentliche Web-Schnittstelle (nur Lesezugriff):
    https://www.crystallography.net/cod/result?formula=C%20Si&format=json
    https://www.crystallography.net/cod/result?text=moissanite&format=json
    https://www.crystallography.net/cod/<ID>.cif
Es werden nur die Suchbegriffe an COD gesendet.
"""
import json
import os
import re
import time
import urllib.error
import urllib.parse
import urllib.request

BASE = "https://www.crystallography.net/cod/"
HEADERS = {"User-Agent": "CIF-to-MPD (EDDIDAT)"}
MAX_BYTES = 20 * 1024 * 1024            # Abbruch bei zu grossen Antworten (zu allgemeine Suche)

_ELEMENT = re.compile(r"([A-Z][a-z]?)\s*(\d*\.?\d*)")


def looks_like_formula(s):
    """True, wenn die Eingabe wie eine chemische Formel aussieht (z. B. SiC, Al2O3, Fe3 O4)."""
    s = s.strip()
    return bool(s) and re.fullmatch(r"(?:[A-Z][a-z]?\s*\d*\.?\d*\s*)+", s) is not None


def formula_to_cod(s):
    """Wandelt eine Formel in die COD-Schreibweise um: Elemente nach Hill-System sortiert, durch Leerzeichen getrennt
    ('SiC' -> 'C Si', 'Al2O3' -> 'Al2 O3', 'Fe3O4' -> 'Fe3 O4'). Mit Kohlenstoff: C, H, dann alphabetisch; sonst alphabetisch."""
    counts = {}
    for el, n in _ELEMENT.findall(s):
        counts[el] = counts.get(el, 0.0) + (float(n) if n else 1.0)
    if not counts:
        raise ValueError("Keine Elemente erkannt.")
    if "C" in counts:
        order = [e for e in ("C", "H") if e in counts] + sorted(e for e in counts if e not in ("C", "H"))
    else:
        order = sorted(counts)
    fmt = lambda e: e + ("" if counts[e] == 1 else ("%g" % counts[e]))
    return " ".join(fmt(e) for e in order)


def _get(url, timeout=40, retries=7):
    """Liest eine URL, mit mehreren Versuchen (der COD-Server bricht Verbindungen gelegentlich ab)."""
    last = None
    for i in range(retries):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=timeout) as r:
                data = r.read(MAX_BYTES + 1)
            if len(data) > MAX_BYTES:
                raise ValueError("Die Antwort ist zu gross - bitte genauer suchen.")
            return data
        except ValueError:
            raise
        except Exception as e:            # Netzwerk-, SSL-, Zeitueberschreitung
            last = e
            time.sleep(2.0)
    raise ConnectionError("COD ist nicht erreichbar oder antwortet nicht (%s)." % str(last)[:120])


def search(query, timeout=40):
    """Sucht in COD. Eine Formel ('SiC', 'Al2O3') wird als Formelsuche, alles andere ('moissanite', 'quartz') als Textsuche
    (Name, Mineral, Titel) ausgefuehrt. Rueckgabe: Liste von Dictionaries (nach COD-Nummer sortiert)."""
    query = query.strip()
    if not query:
        raise ValueError("Bitte eine Verbindung eingeben.")
    if looks_like_formula(query):
        params = {"formula": formula_to_cod(query), "format": "json"}
        mode = "formula"
    else:
        params = {"text": query, "format": "json"}
        mode = "text"
    raw = _get(BASE + "result?" + urllib.parse.urlencode(params), timeout=timeout)
    try:
        items = json.loads(raw.decode("utf-8", "replace"))
    except json.JSONDecodeError:
        raise ValueError("COD hat keine auswertbare Antwort geliefert.")
    out = []
    for x in items:
        f = (x.get("formula") or "").strip()
        f = re.sub(r"^-\s*|\s*-$", "", f)
        out.append(dict(
            id=str(x.get("file", "")), formula=f, name=x.get("mineral") or x.get("commonname") or x.get("chemname") or "",
            sg=x.get("sg") or "", a=x.get("a"), b=x.get("b"), c=x.get("c"), alpha=x.get("alpha"), beta=x.get("beta"), gamma=x.get("gamma"),
            year=x.get("year") or "", title=x.get("title") or "", journal=x.get("journal") or "", doi=x.get("doi") or "",
            temp=x.get("celltemp") or x.get("diffrtemp") or "", pressure=x.get("cellpressure") or x.get("diffrpressure") or "",
            mode=mode, query=params.get("formula") or params.get("text")))
    out.sort(key=lambda r: int(r["id"]) if r["id"].isdigit() else 0)
    return out


def download_cif(cod_id, cache_dir, timeout=40):
    """Laedt die CIF-Datei (https://www.crystallography.net/cod/<ID>.cif) in den Zwischenspeicher und gibt den Pfad zurueck."""
    if not re.fullmatch(r"\d{7}", str(cod_id)):
        raise ValueError("Ungueltige COD-Nummer: %r" % cod_id)
    os.makedirs(cache_dir, exist_ok=True)
    path = os.path.join(cache_dir, "COD_%s.cif" % cod_id)
    if os.path.isfile(path) and os.path.getsize(path) > 200:
        return path
    data = _get(BASE + "%s.cif" % cod_id, timeout=timeout)
    text = data.decode("utf-8", "replace")
    if "_cell_length_a" not in text:
        raise ValueError("Die heruntergeladene Datei ist keine gueltige CIF-Datei.")
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)
    return path
