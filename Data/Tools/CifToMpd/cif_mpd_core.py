"""
cif_mpd_core.py  -  Rechenkern fuer "CIF to MPD" (ohne GUI).

Aus einer CIF-Datei werden die Angaben einer EDDIDAT-Materialdatei (.mpd) bestimmt, die Reflexliste mit
berechneten Intensitaeten erzeugt und die Linienlagen fuer ein simuliertes Spektrum berechnet.
Benoetigt:  pip install gemmi numpy
"""
import math
import os
from fractions import Fraction

import numpy as np
import gemmi

HC = 12.398420          # keV * Angstroem
AVOGADRO_1E24 = 0.602214076

SYSTEMS = ("triclinic", "monoclinic", "orthorhombic", "tetragonal", "trigonal", "hexagonal", "cubic")


# --------------------------------------------------------------------------------------------------
def load_cif(path):
    """Liest die CIF-Datei als kleine Struktur (Zelle, Raumgruppe, Atomlagen, Besetzung, Auslenkung)."""
    small = gemmi.read_small_structure(path)
    if len(small.sites) == 0:
        raise ValueError("Die CIF-Datei enthaelt keine Atomlagen (_atom_site_...).")
    return small


def _crystal_system(sg):
    s = sg.crystal_system_str()
    return s if s in SYSTEMS else "triclinic"


def _system_from_cell(a, b, c, al, be, ga, tol=1e-3, atol=0.01):
    eq = lambda x, y: abs(x - y) < tol * max(x, y)
    r90 = lambda x: abs(x - 90) < atol
    if r90(al) and r90(be) and r90(ga):
        if eq(a, b) and eq(b, c):
            return "cubic"
        return "tetragonal" if eq(a, b) or eq(b, c) or eq(a, c) else "orthorhombic"
    if r90(al) and r90(be) and abs(ga - 120) < atol and eq(a, b):
        return "hexagonal"
    if sum(r90(x) for x in (al, be, ga)) == 2:
        return "monoclinic"
    return "triclinic"


def mpd_parameters(small, density=None):
    """Alle Angaben fuer die .mpd-Datei (Dictionary). Die Dichte wird aus Zelle und Inhalt berechnet."""
    cell = small.cell
    sg = small.spacegroup
    # Atome der Elementarzelle (mit Besetzung) -> Anzahl je Element
    counts, order = {}, []
    for s in small.get_all_unit_cell_sites():
        el = s.element.name
        if el not in counts:
            counts[el] = 0.0
            order.append(el)
        counts[el] += s.occ
    elems = order
    cnt = np.array([counts[e] for e in elems])
    weights = [gemmi.Element(e).weight for e in elems]
    zlist = [gemmi.Element(e).atomic_number for e in elems]
    # Stoechiometrie: gekuerztes ganzzahliges Verhaeltnis, sonst relativ zur kleinsten Menge
    if np.allclose(cnt, np.round(cnt), atol=1e-3) and cnt.min() > 0.5:
        ic = [int(round(c)) for c in cnt]
        g = math.gcd(*ic) if len(ic) > 1 else ic[0]
        stoich = [c / g for c in ic]
    else:
        stoich = list(cnt / cnt.min())
    volume = cell.volume
    mass = float(sum(c * w for c, w in zip(cnt, weights)))
    dens_calc = mass / (volume * AVOGADRO_1E24)

    system = _crystal_system(sg)
    a, b, c = cell.a, cell.b, cell.c
    al, be, ga = cell.alpha, cell.beta, cell.gamma
    note = ""
    if sg.number == 1:                              # CIF ohne Symmetrie (P1): Kristallsystem aus der Zellmetrik schaetzen
        g = _system_from_cell(a, b, c, al, be, ga)
        if g != "triclinic":
            system = g
            note = "CIF ohne Raumgruppe (P1): Kristallsystem aus den Zellparametern abgeleitet."

    if system == "trigonal" and abs(a - b) < 1e-3 * a and abs(a - c) < 1e-3 * a and abs(al - 90) > 0.01 and abs(al - 120) > 0.01:
        # rhomboedrische Aufstellung -> hexagonale Achsen
        ah = 2 * a * math.sin(math.radians(al) / 2)
        ch = a * math.sqrt(3 * (1 + 2 * math.cos(math.radians(al))))
        a, b, c = ah, ah, ch
        note = "Rhomboedrische Zelle in hexagonale Achsen umgerechnet."
    if system == "cubic":
        lat = [a]
    elif system in ("hexagonal", "trigonal"):
        lat = [a, c]
    else:
        lat = [a, b, c]
    if system in ("monoclinic", "triclinic"):
        note = (note + " " if note else "") + "Die Winkel (%.3f, %.3f, %.3f) koennen im .mpd-Format nicht gespeichert werden." % (al, be, ga)
    return dict(
        elements=elems, stoich=stoich, zlist=zlist, weights=weights,
        density=density if density else dens_calc, density_calc=dens_calc,
        lattice_type="none", lattice=[x / 10.0 for x in lat],                    # nm
        system=system, spacegroup="%s (Nr. %d)" % (sg.hm, sg.number),
        cell=(cell.a, cell.b, cell.c, cell.alpha, cell.beta, cell.gamma), volume=volume, note=note,
    )


# --------------------------------------------------------------------------------------------------
def _multiplicity(ops, hkl):
    """Zahl der symmetrieaequivalenten Reflexe im Pulverdiagramm (Punktgruppe + Friedel-Paar)."""
    s = set()
    for op in ops.sym_ops:
        h = tuple(op.apply_to_hkl(list(hkl)))
        s.add(h)
        s.add((-h[0], -h[1], -h[2]))
    return len(s)


def reflections(small, dmin_nm=0.04, use_dw=True):
    """Liste der symmetrie-unabhaengigen Reflexe: hkl, d (nm), Multiplizitaet, |F|^2, I = m*|F|^2 (rel. zum staerksten, 0..1).
    Auslöschungen durch die Raumgruppe fehlen von vornherein, ausserdem fallen Reflexe mit verschwindendem |F|^2 weg."""
    st = small
    saved = []
    if not use_dw:                                    # Debye-Waller-Faktoren voruebergehend abschalten
        for s_ in st.sites:
            saved.append((s_.u_iso, s_.aniso))
            s_.u_iso = 0.0
            s_.aniso = gemmi.SMat33d(0, 0, 0, 0, 0, 0)
    sg = st.spacegroup
    ops = sg.operations()
    calc = gemmi.StructureFactorCalculatorX(st.cell)
    hk = gemmi.make_miller_array(st.cell, sg, dmin_nm * 10.0, unique=True)
    out = []
    for h in hk:
        hkl = (int(h[0]), int(h[1]), int(h[2]))
        if hkl == (0, 0, 0) or ops.is_systematically_absent(hkl):
            continue
        d = st.cell.calculate_d(hkl) / 10.0
        F = calc.calculate_sf_from_small_structure(st, hkl)
        f2 = abs(F) ** 2
        m = _multiplicity(ops, hkl)
        out.append(dict(hkl=hkl, d=d, m=m, F2=f2, I=m * f2))
    out = _merge_equivalent(out)
    if not use_dw:
        for s_, (u, an) in zip(st.sites, saved):
            s_.u_iso, s_.aniso = u, an
    if not out:
        return []
    imax = max(r["I"] for r in out)
    for r in out:
        r["Irel"] = r["I"] / imax if imax > 0 else 0.0
    out.sort(key=lambda r: (-r["d"], r["hkl"]))
    return out


def _merge_equivalent(refl, tol=1e-4):
    """Fasst Reflexe mit gleichem d und gleichem |F|^2 zusammen (bei Strukturen ohne Symmetrie in der CIF)."""
    refl = sorted(refl, key=lambda r: -r["d"])
    out = []
    for r in refl:
        for o in out[-12:]:
            if abs(o["d"] - r["d"]) / r["d"] < tol and abs(o["F2"] - r["F2"]) <= 1e-3 * max(o["F2"], r["F2"], 1e-12):
                o["m"] += r["m"]
                o["I"] = o["m"] * o["F2"]
                if _rep_key(r["hkl"]) > _rep_key(o["hkl"]):
                    o["hkl"] = r["hkl"]
                break
        else:
            out.append(dict(r))
    return out


def _rep_key(hkl):
    return (sum(1 for x in hkl if x >= 0), tuple(sorted(hkl, reverse=True)), hkl)


def hkl_label(hkl):
    """Schreibweise fuer die .mpd-Datei: positive einstellige Indizes (aequivalente Familienvertreter)."""
    return "%d%d%d" % tuple(abs(int(x)) for x in hkl)


def hkl_for_mpd(hkl, system):
    h = [abs(int(x)) for x in hkl]
    return h


# --------------------------------------------------------------------------------------------------
def write_mpd(path, name, p, refl):
    """Schreibt die .mpd-Datei. p: Angaben (wie von mpd_parameters, ggf. vom Benutzer geaendert),
    refl: Liste (hkl-Tripel, d in nm)."""
    f = lambda xs, fmt: "".join(fmt % x for x in xs)
    lines = [
        "Dateiname:  %s.mpd" % name, " ",
        "Elementliste:", "".join("%-4s" % e for e in p["elements"]), " ",
        "Stoechiometrieliste:", f(p["stoich"], "  %.2f  "), " ",
        "Ordnungszahlliste:", f(p["zlist"], "  %d.  "), " ",
        "Atomgewichtsliste (in g/mol):", f(p["weights"], " %.2f  "), " ",
        "Materialdichte (in g/cm^3):", " %.3f" % p["density"], " ",
        "Gittertyp:", p.get("lattice_type", "none"), " ",
        "Gitterparameter (in nm):", "  ".join("%.5f" % v for v in p["lattice"]), " ",
        "hkl- und d-Wertliste:",
    ]
    skipped = 0
    for hkl, d in refl:
        if max(abs(int(x)) for x in hkl) > 9:
            skipped += 1                              # Format: einstellige Indizes
            continue
        lines.append("%s   %.6f " % (hkl_label(hkl), d))
    with open(path, "w", encoding="ascii", newline="\r\n") as fh:
        fh.write("\n".join(lines) + "\n")
    return skipped


# --------------------------------------------------------------------------------------------------
def lorentz_polarization(tth_deg):
    """Winkeldispersiver Fall: (1 + cos^2 2theta) / (sin^2 theta cos theta)."""
    th = np.radians(np.asarray(tth_deg, float) / 2.0)
    return (1 + np.cos(2 * th) ** 2) / (np.sin(th) ** 2 * np.cos(th))


def spectrum_lines(refl, mode, tth=None, wavelength=None, xmin=None, xmax=None, lp=False):
    """Linienlagen und Intensitaeten.
    mode 'ED': x = Energie in keV bei festem 2theta (tth in Grad);  mode 'AD': x = 2theta in Grad bei Wellenlaenge (Angstroem).
    Linien mit |dd/d| < 1e-4 werden zusammengefasst. Rueckgabe: Liste (x, I, d, [hkl-Beschriftungen]) , I in Einheiten m*|F|^2 (ggf. mit LP)."""
    lines = []
    for r in refl:
        dA = r["d"] * 10.0
        if mode == "ED":
            x = HC / (2 * dA * math.sin(math.radians(tth) / 2))
            I = r["I"]
        else:
            s = wavelength / (2 * dA)
            if s >= 1:
                continue
            x = 2 * math.degrees(math.asin(s))
            I = r["I"] * (float(lorentz_polarization(x)) if lp else 1.0)
        if xmin is not None and (x < xmin or x > xmax):
            continue
        lines.append([x, I, r["d"], [hkl_label(r["hkl"])]])
    lines.sort(key=lambda t: t[2], reverse=True)
    merged = []
    for l in lines:
        if merged and abs(merged[-1][2] - l[2]) / l[2] < 1e-4:
            m = merged[-1]
            m[1] += l[1]
            m[3].append(l[3][0])
        else:
            merged.append(l)
    return merged


def broaden(x, lines, fwhm):
    """Summe von Gauss-Linien (Flaeche ~ Intensitaet) auf der Achse x."""
    y = np.zeros_like(x, dtype=float)
    sig = fwhm / 2.3548
    for (x0, I, _, _) in lines:
        y += I * np.exp(-0.5 * ((x - x0) / sig) ** 2) / (sig * math.sqrt(2 * math.pi))
    return y
