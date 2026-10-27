#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
bcf_tool.py - BCF-Werkzeug fuer den Tab "BCF import" der EDDIDAT-GUI
====================================================================
Liest Bruker-Mappings (.bcf), die energiedispersive Beugungsspektren pro Bildpunkt enthalten, und
erzeugt daraus MAT-Dateien, die der erweiterte Loader LoadXFlashFileGUI.m (Diffraktometer Xlab-IKZ) liest.

Unterbefehle
  info    --bcf F                       Kopfdaten als JSON (Bildgroesse, Pixelgroesse, Kanaele, Energieachse, Messzeit)
  cache   --bcf F --out C.mat --bin 8   grober Uebersichtswuerfel (Bloecke x Kanaele) fuer die GUI
  export  --bcf F --outdir D --bin 4    Streifen-MAT-Dateien (optional nur ein Rechteck, optional ohne Probenmaske)

Ausgabe fuer MATLAB: Zeilen "PROGRESS ..." und zum Schluss genau eine Zeile "RESULT {json}".
Bei Fehlern: Zeile "ERROR <Text>" und Exit-Code 1.

Voraussetzungen (einmalig):  pip install rosettasciio numpy scipy
Format der MAT-Dateien siehe bcf_zu_eddidat_streifen.py (E, Counts, X, Y, TwoTheta, RealTimeMs, LifeTimeMs, Names, Source).
Koordinaten: Ursprung = obere linke Ecke der Map, x nach rechts, y nach unten, in mm.
"""
import argparse, csv, json, os, sys, time
import numpy as np


def say(msg):
    print("PROGRESS " + msg, flush=True)


def fail(msg):
    print("ERROR " + msg, flush=True)
    sys.exit(1)


def read_header(bcf):
    try:
        from rsciio.bruker._api import BCF_reader
    except ImportError as e:
        fail(f"Fehlendes Paket ({e}). Bitte installieren: pip install rosettasciio numpy scipy")
    if not os.path.isfile(bcf):
        fail(f"Datei nicht gefunden: {bcf}")
    h = BCF_reader(bcf).header
    w, hh = int(h.image.width), int(h.image.height)
    info = dict(
        Datei=os.path.basename(bcf), Width=w, Height=hh,
        PixelXum=float(h.x_res), PixelYum=float(h.y_res), Channels=int(h.channel_count),
        MsPerPixel=float(h.calc_real_time()) * 1000.0 / (w * hh),
        Name=str(getattr(h, "name", "")),
    )
    return h, info


def lazy_axes(bcf):
    from rsciio.bruker import file_reader
    d = file_reader(bcf, select_type="spectrum_image", lazy=True)[0]
    ae = d["axes"][2]
    md = d.get("metadata", {})
    inst = md.get("Acquisition_instrument", {}).get("SEM", {})
    extra = dict(
        E0=float(ae["offset"]), EStep=float(ae["scale"]),
        ElevationAngle=float(inst.get("Detector", {}).get("EDS", {}).get("elevation_angle", float("nan"))),
        BeamEnergy_kV=float(inst.get("beam_energy", float("nan"))),
        Date=str(md.get("General", {}).get("date", "")),
    )
    return extra


def cmd_info(a):
    h, info = read_header(a.bcf)
    info.update(lazy_axes(a.bcf))
    print("RESULT " + json.dumps(info), flush=True)


def read_binned(a, B):
    """Liest die BCF-Datei mit n x n Binning, schneidet bei emax ab; gibt (data[ny,nx,nE], E, header_info) zurueck."""
    from rsciio.bruker import file_reader
    h, info = read_header(a.bcf)
    t0 = time.time()
    say(f"Lese {os.path.basename(a.bcf)} (Binning {B}x{B}, bis {a.emax} keV) ...")
    d = file_reader(a.bcf, select_type="spectrum_image", downsample=B, cutoff_at_kV=a.emax, lazy=False)[0]
    data = d["data"]
    ae = d["axes"][2]
    E_all = ae["offset"] + ae["scale"] * np.arange(ae["size"])
    ny, nx = info["Height"] // B, info["Width"] // B           # nur volle Bloecke, unvollstaendige Randbloecke entfallen
    data = data[:ny, :nx]
    say(f"Cube {data.shape} gelesen in {time.time() - t0:.0f} s")
    return data, E_all, info


def cmd_cache(a):
    import scipy.io as sio
    B = a.bin
    data, E_all, info = read_binned(a, B)
    sel = (E_all >= a.emin) & (E_all <= a.emax)
    cube = data[:, :, sel]
    mx = int(cube.max())
    cube = cube.astype(np.uint16 if mx <= 65535 else np.uint32)
    d = dict(Cube=cube, E=E_all[sel].reshape(1, -1), PixelXum=info["PixelXum"], PixelYum=info["PixelYum"], Bin=B,
             Width=info["Width"], Height=info["Height"], MsPerPixel=info["MsPerPixel"], BcfFile=os.path.abspath(a.bcf),
             BcfSize=os.path.getsize(a.bcf), BcfMTime=os.path.getmtime(a.bcf), Emin=a.emin, Emax=a.emax)
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    sio.savemat(a.out, d, do_compression=True)
    say(f"Cache gespeichert: {a.out} ({os.path.getsize(a.out) / 1e6:.1f} MB)")
    print("RESULT " + json.dumps(dict(out=os.path.abspath(a.out), blocks=[int(cube.shape[1]), int(cube.shape[0])], channels=int(cube.shape[2]), max=mx)), flush=True)


def cmd_export(a):
    import scipy.io as sio
    B = a.bin
    if B < 2:
        fail("Binning >= 2 erforderlich.")
    emax_out = a.emax                                            # Energiebereich der Ausgabe
    if a.ref_fenster and a.ref_fenster.lower() != "none":
        a.emax = max(a.emax, float(a.ref_fenster.split(",")[1]) + 0.5)   # fuer die Maske noch die rechte Flanke lesen
    data, E_all, info = read_binned(a, B)
    a.emax = emax_out
    psx, psy = info["PixelXum"] / 1000.0, info["PixelYum"] / 1000.0
    ny, nx = data.shape[0], data.shape[1]
    sel = (E_all >= a.emin) & (E_all <= a.emax)
    E = E_all[sel]
    bw, bh = B * psx, B * psy                                   # Blockgroesse in mm
    # Bereich (Rechteck) in Blockindizes: Blockmitte muss im Rechteck liegen
    if a.region:
        x0, x1, y0, y1 = [float(v) for v in a.region.split(",")]
        bx0 = max(0, int(np.ceil(x0 / bw - 0.5))); bx1 = min(nx, int(np.floor(x1 / bw - 0.5)) + 1)
        by0 = max(0, int(np.ceil(y0 / bh - 0.5))); by1 = min(ny, int(np.floor(y1 / bh - 0.5)) + 1)
    else:
        bx0, bx1, by0, by1 = 0, nx, 0, ny
    if bx1 <= bx0 or by1 <= by0:
        fail("Der gewaehlte Bereich enthaelt keinen vollstaendigen Block.")
    region_limited = (by0 > 0 or by1 < ny or bx0 > 0 or bx1 < nx)

    # Probenmaske ueber einen Referenzreflex (ueber die GESAMTE Map bestimmt, Referenzwert = Perzentil)
    keep = np.ones((ny, nx), bool); net = None; ref = None
    if a.ref_fenster and a.ref_fenster.lower() != "none" and a.schwelle > 0:
        lo, hi = [float(v) for v in a.ref_fenster.split(",")]
        w = lambda l, h_: (E_all >= l) & (E_all < h_)
        pm, lm, rm = w(lo, hi), w(lo - 0.35, lo - 0.05), w(hi + 0.10, hi + 0.40)
        net = data[:, :, pm].sum(2, dtype=np.float64) - (data[:, :, lm].mean(2) + data[:, :, rm].mean(2)) / 2 * pm.sum()
        ref = float(np.percentile(net, a.ref_perzentil)); keep = net >= a.schwelle * ref
        say(f"Referenz {lo}-{hi} keV: {a.ref_perzentil:g}. Perzentil = {ref:.0f} Counts, Schwelle {a.schwelle * ref:.0f}; Probe: {keep.sum()} von {keep.size} Bloecken")
    mask = np.zeros_like(keep); mask[by0:by1, bx0:bx1] = True
    keep = keep & mask
    if not keep.any():
        fail("Keine Bloecke im Bereich erfuellen die Auswahl (Referenzreflex/Schwelle pruefen).")

    prefix = a.prefix or os.path.splitext(os.path.basename(a.bcf))[0]
    ms = a.ms_pro_pixel if a.ms_pro_pixel > 0 else info["MsPerPixel"]
    os.makedirs(a.outdir, exist_ok=True)
    strip_blocks = max(1, int(round(a.streifenbreite_mm / bw))) if a.streifenbreite_mm > 0 else (bx1 - bx0)
    nstrips = int(np.ceil((bx1 - bx0) / strip_blocks))
    files, rows, total = [], [], 0
    for s in range(nstrips):
        c0 = bx0 + s * strip_blocks; c1 = min(bx0 + (s + 1) * strip_blocks, bx1)
        idx = [(by, bx) for bx in range(c0, c1) for by in range(by0, by1) if keep[by, bx]]
        if not idx:
            continue
        C = np.stack([data[by, bx][sel] for by, bx in idx])
        mx = int(C.max())
        if mx > 65535:
            fail(f"Zaehlrate pro Kanal ueberschreitet uint16 ({mx}); kleineres Binning waehlen.")
        C = C.astype(np.uint16)
        X = np.array([(bx + 0.5) * bw for by, bx in idx]); Y = np.array([(by + 0.5) * bh for by, bx in idx])
        names = np.empty((len(idx), 1), dtype=object)
        for i in range(len(idx)):
            names[i, 0] = f"{prefix}_x{int(round(X[i] * 1000)):05d}um_y{int(round(Y[i] * 1000)):04d}um"
        rt = ms * B * B
        src = (f"{os.path.basename(a.bcf)}, {B}x{B} binned, {a.emin}-{a.emax} keV, block columns {c0}-{c1 - 1}, rows {by0}-{by1 - 1}; "
               + (f"only blocks on the sample (ref {a.ref_fenster} keV >= {a.schwelle:.0%} of the {a.ref_perzentil:g}th percentile); " if net is not None else "all blocks; ")
               + "column-wise (y fastest); created with bcf_tool.py")
        dct = {"E": E.reshape(1, -1), "Counts": C, "X": X.reshape(-1, 1), "Y": Y.reshape(-1, 1), "TwoTheta": np.array([[a.tth]]),
               "RealTimeMs": np.array([[rt]]), "LifeTimeMs": np.array([[rt]]), "Names": names, "Source": src}
        xa, xb, ya, yb = c0 * bw, c1 * bw, by0 * bh, by1 * bh
        ypart = f"_y{ya:.3f}-{yb:.3f}" if region_limited else ""
        if nstrips == 1:
            fn = f"{prefix}_x{xa:.3f}-{xb:.3f}{ypart}_B{B}.mat"
        else:
            fn = f"{prefix}_strip{s:02d}_x{xa:.3f}-{xb:.3f}{ypart}_B{B}.mat"
        path = os.path.join(a.outdir, fn)
        sio.savemat(path, dct, do_compression=True)
        total += len(idx); files.append(path)
        full = (c1 - c0) * (by1 - by0)
        rows.append(dict(Datei=fn, x_von_mm=round(xa, 3), x_bis_mm=round(xb, 3), y_von_mm=round(ya, 3), y_bis_mm=round(yb, 3),
                         Bloecke_gesamt=full, Spektren=len(idx), weggelassen=full - len(idx), MB=round(os.path.getsize(path) / 1e6, 2), max_Counts=mx))
        say(f"Datei {len(files)}/{nstrips}: {fn} ({len(idx)} Spektren, {os.path.getsize(path) / 1e6:.2f} MB)")
    with open(os.path.join(a.outdir, f"{prefix}_B{B}_index.csv"), "w", newline="", encoding="utf-8-sig") as f:
        wr = csv.DictWriter(f, fieldnames=list(rows[0].keys()), delimiter=";"); wr.writeheader(); wr.writerows(rows)
    print("RESULT " + json.dumps(dict(files=files, spectra=total, bin=B, outdir=os.path.abspath(a.outdir), blocks_in_region=int((bx1 - bx0) * (by1 - by0)),
                                      region_blocks=[bx0, bx1, by0, by1], region_mm=[bx0 * bw, bx1 * bw, by0 * bh, by1 * bh], ms_per_pixel=ms,
                                      ref=ref)), flush=True)


def main():
    p = argparse.ArgumentParser(description="BCF-Werkzeug fuer EDDIDAT")
    sp = p.add_subparsers(dest="cmd", required=True)
    for name in ("info", "cache", "export"):
        q = sp.add_parser(name)
        q.add_argument("--bcf", required=True)
        if name in ("cache", "export"):
            q.add_argument("--bin", type=int, default=8 if name == "cache" else 4)
            q.add_argument("--emin", type=float, default=0.5 if name == "cache" else 5.0)
            q.add_argument("--emax", type=float, default=15.0)
        if name == "cache":
            q.add_argument("--out", required=True)
        if name == "export":
            q.add_argument("--outdir", required=True)
            q.add_argument("--region", default=None, help="x0,x1,y0,y1 in mm (Blockmitte im Rechteck); Standard: ganze Map")
            q.add_argument("--streifenbreite-mm", type=float, default=1.0, help="0 = alles in eine Datei")
            q.add_argument("--ref-fenster", default="none", help="Energiefenster des Referenzreflexes lo,hi (keV) oder none")
            q.add_argument("--schwelle", type=float, default=0.30)
            q.add_argument("--ref-perzentil", type=float, default=75.0)
            q.add_argument("--prefix", default=None)
            q.add_argument("--2theta", dest="tth", type=float, default=125.9)
            q.add_argument("--ms-pro-pixel", type=float, default=0.0, help="0 = aus der BCF-Datei")
    a = p.parse_args()
    {"info": cmd_info, "cache": cmd_cache, "export": cmd_export}[a.cmd](a)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as e:                       # jede andere Ausnahme als ERROR-Zeile melden
        fail(f"{type(e).__name__}: {e}")
