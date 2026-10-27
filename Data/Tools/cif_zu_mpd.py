#!/usr/bin/env python
"""
cif_zu_mpd.py  -  erzeugt aus einer CIF-Datei eine EDDIDAT-Materialdatei (.mpd).

Aufruf
    python cif_zu_mpd.py Si.cif
    python cif_zu_mpd.py Si.cif --name Si_Probe --outdir D:\\EDDIDAT_github\\Data\\Materials --dmin 0.05

Voraussetzung:  pip install pymatgen

Die .mpd-Datei enthaelt (wie die vorhandenen Dateien in Data\\Materials):
    Elementliste, Stoechiometrieliste, Ordnungszahlliste, Atomgewichtsliste (g/mol), Materialdichte (g/cm^3),
    Gittertyp (hier immer "none"), Gitterparameter (nm), hkl- und d-Wertliste (d in nm).
Die hkl-Liste enthaelt je symmetrie-unabhaengiger Netzebenenfamilie einen Eintrag. Reflexe, die durch die
Raumgruppe ausgeloescht sind (Systematische Ausloeschungen), werden ueber den Strukturfaktor erkannt und fehlen.
"""
import argparse
import os
import sys


def main():
    p = argparse.ArgumentParser(description="CIF -> EDDIDAT .mpd")
    p.add_argument("cif", help="CIF-Datei")
    p.add_argument("--name", default=None, help="Name der .mpd-Datei (ohne Endung); Standard: Name der CIF-Datei")
    p.add_argument("--outdir", default=".", help="Ausgabeordner (Standard: aktueller Ordner; fuer EDDIDAT: Data\\Materials)")
    p.add_argument("--dmin", type=float, default=0.04, help="kleinster d-Wert in nm (Standard 0.04)")
    p.add_argument("--density", type=float, default=None, help="Dichte in g/cm^3 (Standard: aus der Zelle berechnet)")
    p.add_argument("--min-intensity", type=float, default=1e-3,
                   help="Reflexe unter diesem Anteil der staerksten Intensitaet werden weggelassen (Standard 1e-3)")
    a = p.parse_args()

    try:
        from pymatgen.core import Structure
        from pymatgen.analysis.diffraction.xrd import XRDCalculator
        from pymatgen.symmetry.analyzer import SpacegroupAnalyzer
    except ImportError:
        sys.exit("pymatgen fehlt: pip install pymatgen")

    struct = Structure.from_file(a.cif)
    name = a.name or os.path.splitext(os.path.basename(a.cif))[0]

    # --- Zusammensetzung (Verhaeltnis der Atome, gekuerzt) ---
    comp = struct.composition.reduced_composition
    elems = [str(e) for e in comp.elements]
    amounts = [comp[e] for e in comp.elements]
    zlist = [e.Z for e in comp.elements]
    mlist = [float(e.atomic_mass) for e in comp.elements]
    density = a.density if a.density else float(struct.density)

    # --- Gitterparameter (konventionelle Standardzelle) ---
    sga = SpacegroupAnalyzer(struct, symprec=1e-3)
    conv = sga.get_conventional_standard_structure()
    la = conv.lattice
    system = sga.get_crystal_system()                         # cubic, hexagonal, trigonal, tetragonal, ...
    A, B, C = (x / 10.0 for x in (la.a, la.b, la.c))          # Angstroem -> nm
    if system == "cubic":
        lat = [A]
    elif system in ("hexagonal", "trigonal"):
        lat = [A, C]
    else:                                                     # tetragonal, orthorhombic, monoclinic, triclinic
        lat = [A, B, C]
    if system in ("monoclinic", "triclinic"):
        print("Hinweis: Die Winkel (%.3f %.3f %.3f) koennen nicht in der .mpd-Datei stehen." % la.angles, file=sys.stderr)

    # --- hkl- und d-Werte: Strukturfaktor mit kleiner Wellenlaenge, damit alle Reflexe bis dmin erreichbar sind ---
    wl = 0.5594                                               # Angstroem (Ag K-alpha), kleiner als 2*dmin
    xrd = XRDCalculator(wavelength=wl)
    pat = xrd.get_pattern(conv, scaled=False, two_theta_range=(0, 180))
    imax = max(pat.y)
    rows = {}
    for d_A, inten, hkls in zip(pat.d_hkls, pat.y, pat.hkls):
        if inten < a.min_intensity * imax or d_A / 10.0 < a.dmin:
            continue
        for h in hkls:
            v = [int(x) for x in h["hkl"]]
            if len(v) == 4:                                   # hexagonal/trigonal: (h k i l) -> (h k l)
                hk = sorted(abs(x) for x in v[:3])[:2]        # aequivalente Schreibweise mit den zwei kleinsten Indizes
                v = [hk[0], hk[1], v[3]]
            idx = tuple(abs(x) for x in v)                    # Familienvertreter mit positiven Indizes
            if max(idx) > 9:
                continue                                      # das Format haelt nur einstellige Indizes
            rows[idx] = d_A / 10.0
    table = sorted(rows.items(), key=lambda kv: (-kv[1], kv[0]))

    # --- schreiben ---
    os.makedirs(a.outdir, exist_ok=True)
    out = os.path.join(a.outdir, name + ".mpd")
    f = lambda xs, fmt: "".join(fmt % x for x in xs)
    lines = [
        "Dateiname:  %s.mpd" % name, " ",
        "Elementliste:", "".join("%-4s" % e for e in elems), " ",
        "Stoechiometrieliste:", f(amounts, "  %.2f  "), " ",
        "Ordnungszahlliste:", f(zlist, "  %d.  "), " ",
        "Atomgewichtsliste (in g/mol):", f(mlist, " %.2f  "), " ",
        "Materialdichte (in g/cm^3):", " %.3f" % density, " ",
        "Gittertyp:", "none", " ",
        "Gitterparameter (in nm):", "  ".join("%.5f" % v for v in lat), " ",
        "hkl- und d-Wertliste:",
    ]
    lines += ["%d%d%d   %.6f " % (h, k, l, d) for (h, k, l), d in table]
    with open(out, "w", encoding="ascii", newline="\r\n") as fh:
        fh.write("\n".join(lines) + "\n")
    print("Raumgruppe %s (%s), %d Reflexe -> %s" % (sga.get_space_group_symbol(), system, len(table), out))


if __name__ == "__main__":
    main()
