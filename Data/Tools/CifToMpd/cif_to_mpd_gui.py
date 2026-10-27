"""
CIF to MPD  -  kleine GUI zum Erzeugen von EDDIDAT-Materialdateien (.mpd) aus CIF-Dateien.

  1) CIF-Datei laden            2) Parameter berechnen und kontrollieren (editierbar)
  3) Reflexliste mit berechneten Intensitaeten pruefen (einzelne Reflexe abwaehlbar)
  4) als .mpd exportieren       5) Spektrum simulieren (energiedispersiv bei festem 2theta oder winkeldispersiv)

Start:  python cif_to_mpd_gui.py [datei.cif]
Benoetigt: gemmi, numpy, matplotlib (tkinter gehoert zu Python)
"""
import json
import math
import os
import sys
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

import numpy as np
import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
from matplotlib.figure import Figure

import cif_mpd_core as core
import cod_search
import threading
import queue

CONFIG = os.path.join(os.path.expanduser("~"), ".cif_to_mpd.json")
RADIATIONS = {"Ag Ka1 (0.5594 A)": 0.55941, "Mo Ka1 (0.7093 A)": 0.70932, "Cu Ka1 (1.5406 A)": 1.54056,
              "Co Ka1 (1.7890 A)": 1.78897, "Fe Ka1 (1.9360 A)": 1.93604, "Cr Ka1 (2.2897 A)": 2.28970}


def load_cfg():
    try:
        with open(CONFIG, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


def save_cfg(d):
    try:
        with open(CONFIG, "w", encoding="utf-8") as f:
            json.dump(d, f)
    except Exception:
        pass


def default_materials_dir():
    here = os.path.dirname(os.path.abspath(sys.argv[0]))
    for rel in ("..\\..\\Materials", "Data\\Materials", "..\\Data\\Materials"):
        p = os.path.normpath(os.path.join(here, rel))
        if os.path.isdir(p):
            return p
    return os.path.expanduser("~")


class App:
    def __init__(self, root):
        self.root = root
        root.title("CIF to MPD")
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        root.geometry("%dx%d+20+20" % (min(1500, int(sw * 0.92)), min(900, int(sh * 0.88))))
        self.cfg = load_cfg()
        import tkinter.font as tkfont
        ttk.Style().configure("Treeview", rowheight=int(tkfont.nametofont("TkDefaultFont").metrics("linespace") * 1.5))
        self.small = None
        self.params = None
        self.refl = []            # alle berechneten Reflexe
        self.use = {}             # Index -> bool
        self.shown = []           # Indizes in der Tabelle
        self.cif_path = ""
        self._build()

    # ------------------------------------------------------------------ Aufbau
    def _build(self):
        left = ttk.Frame(self.root, padding=6)
        left.pack(side="left", fill="y")
        right = ttk.Frame(self.root, padding=6)
        right.pack(side="left", fill="both", expand=True)

        self.nb = ttk.Notebook(left)
        self.nb.pack(fill="both", expand=True)
        tab1 = ttk.Frame(self.nb, padding=4)
        tab2 = ttk.Frame(self.nb, padding=4)
        self.nb.add(tab1, text="1  Source (CIF / COD)")
        self.nb.add(tab2, text="2  Parameters / reflections")

        f1 = ttk.LabelFrame(tab1, text="CIF file", padding=6)
        f1.pack(fill="x")
        ttk.Button(f1, text="Open CIF...", command=self.open_cif).grid(row=0, column=0, sticky="w")
        self.lbl_file = ttk.Label(f1, text="(no file)", width=42)
        self.lbl_file.grid(row=0, column=1, padx=6, sticky="w")
        self.btn_calc = ttk.Button(f1, text="Calculate parameters", command=self.calculate, state="disabled")
        self.btn_calc.grid(row=1, column=0, columnspan=2, sticky="ew", pady=(6, 0))

        self._build_cod(tab1)

        f2 = ttk.LabelFrame(tab2, text="Parameters of the .mpd file (editable)", padding=6)
        f2.pack(fill="x", pady=6)
        self.var = {}
        rows = [("name", "File name"), ("elements", "Elements"), ("stoich", "Stoichiometry"), ("zlist", "Atomic numbers"),
                ("weights", "Atomic weights (g/mol)"), ("density", "Density (g/cm^3)"), ("ltype", "Lattice type"),
                ("lattice", "Lattice parameters (nm)")]
        for i, (k, lab) in enumerate(rows):
            ttk.Label(f2, text=lab).grid(row=i, column=0, sticky="w")
            self.var[k] = tk.StringVar()
            e = ttk.Entry(f2, textvariable=self.var[k], width=40)
            e.grid(row=i, column=1, sticky="ew", padx=4, pady=1)
        f2.columnconfigure(1, weight=1)
        self.lbl_info = ttk.Label(f2, text="", wraplength=430, justify="left", foreground="#335")
        self.lbl_info.grid(row=len(rows), column=0, columnspan=2, sticky="w", pady=(4, 0))

        f3 = ttk.LabelFrame(tab2, text="Reflections", padding=6)
        f3.pack(fill="both", expand=True)
        r = ttk.Frame(f3)
        r.pack(fill="x")
        ttk.Label(r, text="d min (nm)").pack(side="left")
        self.var_dmin = tk.StringVar(value="0.04")
        ttk.Entry(r, textvariable=self.var_dmin, width=6).pack(side="left", padx=4)
        ttk.Label(r, text="min. I (%)").pack(side="left")
        self.var_imin = tk.StringVar(value="0.1")
        ttk.Entry(r, textvariable=self.var_imin, width=5).pack(side="left", padx=4)
        self.var_dw = tk.BooleanVar(value=True)
        ttk.Checkbutton(r, text="Debye-Waller (from CIF)", variable=self.var_dw).pack(side="left", padx=4)
        ttk.Button(r, text="Recalculate", command=self.calc_reflections).pack(side="left", padx=4)
        tv = ttk.Frame(f3)
        tv.pack(fill="both", expand=True, pady=4)
        cols = ("use", "hkl", "d", "m", "I")
        self.tree = ttk.Treeview(tv, columns=cols, show="headings", height=12, selectmode="browse")
        for c, t, w in (("use", "Use", 40), ("hkl", "hkl", 70), ("d", "d (nm)", 90), ("m", "mult.", 50), ("I", "I rel. (%)", 80)):
            self.tree.heading(c, text=t)
            self.tree.column(c, width=w, anchor="center")
        sb = ttk.Scrollbar(tv, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=sb.set)
        self.tree.pack(side="left", fill="both", expand=True)
        sb.pack(side="left", fill="y")
        self.tree.bind("<Double-1>", self.toggle_row)
        b = ttk.Frame(f3)
        b.pack(fill="x")
        ttk.Button(b, text="All", width=6, command=lambda: self.set_all(True)).pack(side="left")
        ttk.Button(b, text="None", width=6, command=lambda: self.set_all(False)).pack(side="left", padx=4)
        self.lbl_count = ttk.Label(b, text="")
        self.lbl_count.pack(side="left", padx=8)
        ttk.Label(f3, text="Double-click a row to include or exclude it.", foreground="#666").pack(anchor="w")

        f4 = ttk.Frame(left, padding=(0, 6, 0, 0))
        f4.pack(fill="x")
        self.btn_export = ttk.Button(f4, text="Export .mpd...", command=self.export, state="disabled")
        self.btn_export.pack(fill="x")

        # ---- rechts: Spektrum
        c = ttk.LabelFrame(right, text="Simulated spectrum (kinematic: m * |F|^2, no flux, absorption or texture)", padding=6)
        c.pack(fill="x")
        self.mode = tk.StringVar(value="ED")
        ttk.Radiobutton(c, text="Energy-dispersive (fixed 2theta)", variable=self.mode, value="ED", command=self._mode_changed).grid(row=0, column=0, columnspan=3, sticky="w")
        ttk.Radiobutton(c, text="Angle-dispersive (wavelength)", variable=self.mode, value="AD", command=self._mode_changed).grid(row=0, column=3, columnspan=3, sticky="w")
        self.var_tth = tk.StringVar(value="16")
        self.var_e0, self.var_e1 = tk.StringVar(value="10"), tk.StringVar(value="100")
        self.var_rad = tk.StringVar(value="Cu Ka1 (1.5406 A)")
        self.var_t0, self.var_t1 = tk.StringVar(value="10"), tk.StringVar(value="140")
        self.var_fwhm = tk.StringVar(value="0.15")
        self.ed_widgets = [ttk.Label(c, text="2theta (deg)"), ttk.Entry(c, textvariable=self.var_tth, width=7),
                           ttk.Label(c, text="E from/to (keV)"), ttk.Entry(c, textvariable=self.var_e0, width=6), ttk.Entry(c, textvariable=self.var_e1, width=6)]
        self.ad_widgets = [ttk.Label(c, text="Radiation"), ttk.Combobox(c, textvariable=self.var_rad, values=list(RADIATIONS), width=18),
                           ttk.Label(c, text="2theta from/to"), ttk.Entry(c, textvariable=self.var_t0, width=6), ttk.Entry(c, textvariable=self.var_t1, width=6)]
        self.lbl_fwhm = ttk.Label(c, text="FWHM (keV)")
        self.var_curve, self.var_lab, self.var_lp = tk.BooleanVar(value=True), tk.BooleanVar(value=True), tk.BooleanVar(value=True)
        self.chk_lp = ttk.Checkbutton(c, text="Lorentz-polarization", variable=self.var_lp)
        ttk.Button(c, text="Update plot", command=self.update_plot).grid(row=0, column=7, padx=8, sticky="e")
        self._layout_mode_widgets(c)
        ttk.Entry(c, textvariable=self.var_fwhm, width=6).grid(row=2, column=1, sticky="w")
        self.lbl_fwhm.grid(row=2, column=0, sticky="w")
        ttk.Checkbutton(c, text="broadened curve", variable=self.var_curve).grid(row=2, column=2, columnspan=2, sticky="w")
        ttk.Checkbutton(c, text="hkl labels", variable=self.var_lab).grid(row=2, column=4, sticky="w")
        self.chk_lp.grid(row=2, column=5, columnspan=2, sticky="w")

        self.fig = Figure(figsize=(7, 5), dpi=100)
        self.ax = self.fig.add_subplot(111)
        self.canvas = FigureCanvasTkAgg(self.fig, master=right)
        NavigationToolbar2Tk(self.canvas, right).pack(side="bottom", fill="x")
        self.canvas.get_tk_widget().pack(fill="both", expand=True)
        self._mode_changed()
        self.ax.set_xlabel("E (keV)")
        self.ax.set_ylabel("relative intensity (%)")
        self.canvas.draw()

    # ------------------------------------------------------------------ COD-Suche
    def _build_cod(self, parent):
        f = ttk.LabelFrame(parent, text="Search the Crystallography Open Database (COD)", padding=6)
        f.pack(fill="both", expand=True, pady=6)
        r = ttk.Frame(f)
        r.pack(fill="x")
        ttk.Label(r, text="Compound").pack(side="left")
        self.var_q = tk.StringVar()
        e = ttk.Entry(r, textvariable=self.var_q, width=22)
        e.pack(side="left", padx=4)
        e.bind("<Return>", lambda ev: self.cod_search())
        self.btn_search = ttk.Button(r, text="Search", command=self.cod_search)
        self.btn_search.pack(side="left")
        ttk.Label(f, text="Formula (SiC, Al2O3, Fe3O4) or name (quartz, moissanite). Needs an internet connection.",
                  foreground="#666", wraplength=430, justify="left").pack(anchor="w", pady=(2, 4))
        tv = ttk.Frame(f)
        tv.pack(fill="both", expand=True)
        cols = ("id", "formula", "name", "sg", "cell", "year")
        self.cod_tree = ttk.Treeview(tv, columns=cols, show="headings", height=10, selectmode="browse")
        for c, t, w in (("id", "COD ID", 75), ("formula", "Formula", 90), ("name", "Name", 130), ("sg", "Space group", 110),
                        ("cell", "a / b / c (A)", 190), ("year", "Year", 50)):
            self.cod_tree.heading(c, text=t, command=lambda c=c: self.cod_sort(c))
            self.cod_tree.column(c, width=w, anchor="w")
        sb = ttk.Scrollbar(tv, orient="vertical", command=self.cod_tree.yview)
        self.cod_tree.configure(yscrollcommand=sb.set)
        self.cod_tree.pack(side="left", fill="both", expand=True)
        sb.pack(side="left", fill="y")
        self.cod_tree.bind("<Double-1>", lambda ev: self.cod_load())
        self.cod_tree.bind("<<TreeviewSelect>>", self.cod_show_detail)
        b = ttk.Frame(f)
        b.pack(fill="x", pady=(4, 0))
        self.btn_cod_load = ttk.Button(b, text="Load selected CIF", command=self.cod_load, state="disabled")
        self.btn_cod_load.pack(side="left")
        self.lbl_cod = ttk.Label(b, text="", foreground="#335")
        self.lbl_cod.pack(side="left", padx=8)
        self.lbl_cod_detail = ttk.Label(f, text="", wraplength=430, justify="left", foreground="#335")
        self.lbl_cod_detail.pack(anchor="w", pady=(4, 0))
        self.cod_rows = {}
        self.suggest_name = ""
        self._q = queue.Queue()
        self.root.after(150, self._poll)

    def _poll(self):
        try:
            while True:
                fn = self._q.get_nowait()
                fn()
        except queue.Empty:
            pass
        self.root.after(150, self._poll)

    def _async(self, work, done):
        """Fuehrt work() in einem Thread aus (die Oberflaeche bleibt bedienbar), done(ergebnis, fehler) laeuft im Hauptthread."""
        def run():
            try:
                res, err = work(), None
            except Exception as e:
                res, err = None, e
            self._q.put(lambda: done(res, err))
        threading.Thread(target=run, daemon=True).start()

    def cod_search(self):
        q = self.var_q.get().strip()
        if not q:
            return
        self.btn_search.config(state="disabled")
        self.lbl_cod.config(text="searching ...")
        self.cod_tree.delete(*self.cod_tree.get_children())
        self.cod_rows = {}
        self._async(lambda: cod_search.search(q), self._cod_done)

    def _cod_done(self, res, err):
        self.btn_search.config(state="normal")
        if err is not None:
            self.lbl_cod.config(text="")
            messagebox.showerror("COD search", str(err))
            return
        self.cod_rows = {r["id"]: r for r in res}

        def f(v):
            try:
                return "%.4g" % float(v)
            except (TypeError, ValueError):
                return "-"
        for r in res:
            cell = " / ".join(f(r[k]) for k in ("a", "b", "c"))
            self.cod_tree.insert("", "end", iid=r["id"], values=(r["id"], r["formula"], r["name"], r["sg"], cell, r["year"]))
        self.lbl_cod.config(text="%d entries" % len(res))
        self.btn_cod_load.config(state="normal" if res else "disabled")
        if not res:
            messagebox.showinfo("COD search", "No entries found. For minerals or names use the name (e.g. quartz), for compounds the formula (e.g. SiO2).")

    def cod_sort(self, col):
        items = [(self.cod_tree.set(i, col), i) for i in self.cod_tree.get_children()]

        def key(t):
            try:
                return (0, float(t[0].split()[0]), "")
            except (ValueError, IndexError):
                return (1, 0.0, t[0].lower())
        rev = getattr(self, "_sort_rev", {}).get(col, False)
        items.sort(key=key, reverse=rev)
        self._sort_rev = {col: not rev}
        for k, (_, i) in enumerate(items):
            self.cod_tree.move(i, "", k)

    def cod_show_detail(self, ev=None):
        sel = self.cod_tree.selection()
        if not sel:
            return
        r = self.cod_rows.get(sel[0])
        if r:
            t = "%s  %s" % (r["title"], ("(" + r["journal"].split(" (")[0] + ", " + r["year"] + ")") if r["journal"] else "")
            extra = []
            if r["temp"]:
                extra.append("T = %s K" % r["temp"])
            if r["pressure"]:
                extra.append("p = %s kPa" % r["pressure"])
            self.lbl_cod_detail.config(text=t + ("\n" + ", ".join(extra) if extra else ""))

    def cod_load(self):
        sel = self.cod_tree.selection()
        if not sel:
            messagebox.showinfo("COD search", "Please select an entry first.")
            return
        cid = sel[0]
        r = self.cod_rows.get(cid, {})
        self.btn_cod_load.config(state="disabled")
        self.lbl_cod.config(text="downloading ...")
        cache = os.path.join(os.path.expanduser("~"), ".cif_to_mpd", "cache")
        self._async(lambda: cod_search.download_cif(cid, cache), lambda res, err: self._cod_loaded(res, err, r))

    def _cod_loaded(self, path, err, r):
        self.btn_cod_load.config(state="normal")
        self.lbl_cod.config(text="")
        if err is not None:
            messagebox.showerror("COD download", str(err))
            return
        base = r.get("name") or r.get("formula") or "COD"
        base = "".join(ch if ch.isalnum() else "_" for ch in base.replace(" ", "")).strip("_")
        self.open_cif(path, suggest="%s_COD%s" % (base, r.get("id", "")))
        self.calculate()

    def _layout_mode_widgets(self, c):
        for i, w in enumerate(self.ed_widgets):
            w.grid(row=1, column=i, sticky="w", padx=(0, 4))
        for i, w in enumerate(self.ad_widgets):
            w.grid(row=1, column=i, sticky="w", padx=(0, 4))

    def _mode_changed(self):
        ed = self.mode.get() == "ED"
        for w in self.ed_widgets:
            w.grid() if ed else w.grid_remove()
        for w in self.ad_widgets:
            w.grid_remove() if ed else w.grid()
        self.lbl_fwhm.config(text="FWHM (keV)" if ed else "FWHM (deg)")
        self.var_fwhm.set("0.15" if ed else "0.10")
        self.chk_lp.state(["disabled"] if ed else ["!disabled"])
        if self.refl:
            self.update_plot()

    # ------------------------------------------------------------------ Aktionen
    def open_cif(self, path=None, suggest=""):
        if not path:
            path = filedialog.askopenfilename(initialdir=self.cfg.get("cif_dir", os.path.expanduser("~")),
                                              filetypes=[("CIF", "*.cif"), ("All", "*.*")], title="Select CIF file")
        if not path:
            return
        try:
            self.small = core.load_cif(path)
        except Exception as e:
            messagebox.showerror("CIF to MPD", "The file could not be read:\n%s" % e)
            return
        self.cif_path = path
        self.suggest_name = suggest
        self.cfg["cif_dir"] = os.path.dirname(path)
        save_cfg(self.cfg)
        self.lbl_file.config(text=os.path.basename(path))
        self.btn_calc.config(state="normal")
        self.params, self.refl = None, []
        self.tree.delete(*self.tree.get_children())
        self.btn_export.config(state="disabled")
        self.lbl_info.config(text="CIF loaded. Press \"Calculate parameters\".")

    def calculate(self):
        if self.small is None:
            return
        try:
            p = core.mpd_parameters(self.small)
        except Exception as e:
            messagebox.showerror("CIF to MPD", "Parameter calculation failed:\n%s" % e)
            return
        self.params = p
        v = self.var
        v["name"].set(self.suggest_name or os.path.splitext(os.path.basename(self.cif_path))[0])
        v["elements"].set(" ".join(p["elements"]))
        v["stoich"].set(" ".join("%g" % round(x, 4) for x in p["stoich"]))
        v["zlist"].set(" ".join(str(x) for x in p["zlist"]))
        v["weights"].set(" ".join("%.2f" % x for x in p["weights"]))
        v["density"].set("%.3f" % p["density"])
        v["ltype"].set(p["lattice_type"])
        v["lattice"].set("  ".join("%.5f" % x for x in p["lattice"]))
        a, b, c, al, be, ga = p["cell"]
        info = "Space group %s, %s\nCell: a=%.4f b=%.4f c=%.4f A, alpha=%.2f beta=%.2f gamma=%.2f, V=%.2f A^3" % (
            p["spacegroup"], p["system"], a, b, c, al, be, ga, p["volume"])
        if p["note"]:
            info += "\n" + p["note"]
        self.lbl_info.config(text=info)
        self.calc_reflections()
        self.nb.select(1)

    def calc_reflections(self):
        if self.small is None:
            return
        try:
            dmin = float(self.var_dmin.get())
            self.refl = core.reflections(self.small, dmin, self.var_dw.get())
        except Exception as e:
            messagebox.showerror("CIF to MPD", "Reflection calculation failed:\n%s" % e)
            return
        self.fill_table()
        self.btn_export.config(state="normal")
        self.update_plot()

    def fill_table(self):
        try:
            imin = float(self.var_imin.get()) / 100.0
        except ValueError:
            imin = 1e-3
        self.tree.delete(*self.tree.get_children())
        self.use = {}
        self.shown = []
        for i, r in enumerate(self.refl):
            if r["Irel"] < imin:
                continue
            self.use[i] = True
            self.shown.append(i)
            self.tree.insert("", "end", iid=str(i), values=("x", core.hkl_label(r["hkl"]), "%.6f" % r["d"], r["m"], "%.1f" % (100 * r["Irel"])))
        self._count()

    def _count(self):
        n = sum(1 for i in self.shown if self.use[i])
        self.lbl_count.config(text="%d reflections, %d used" % (len(self.shown), n))

    def toggle_row(self, ev):
        iid = self.tree.identify_row(ev.y)
        if not iid:
            return
        i = int(iid)
        self.use[i] = not self.use[i]
        self.tree.set(iid, "use", "x" if self.use[i] else "")
        self._count()
        self.update_plot()

    def set_all(self, state):
        for i in self.shown:
            self.use[i] = state
            self.tree.set(str(i), "use", "x" if state else "")
        self._count()
        self.update_plot()

    def used_refl(self):
        return [self.refl[i] for i in self.shown if self.use.get(i)]

    def export(self):
        if not self.refl:
            return
        try:
            v = self.var
            name = v["name"].get().strip()
            if not name:
                raise ValueError("File name is empty.")
            P = dict(elements=v["elements"].get().split(), stoich=[float(x) for x in v["stoich"].get().split()],
                     zlist=[int(float(x)) for x in v["zlist"].get().split()], weights=[float(x) for x in v["weights"].get().split()],
                     density=float(v["density"].get()), lattice_type=v["ltype"].get().strip() or "none",
                     lattice=[float(x) for x in v["lattice"].get().split()])
            n = len(P["elements"])
            if not (len(P["stoich"]) == len(P["zlist"]) == len(P["weights"]) == n) or n == 0:
                raise ValueError("Elements, stoichiometry, atomic numbers and atomic weights must have the same number of entries.")
        except ValueError as e:
            messagebox.showerror("CIF to MPD", "Please check the parameters:\n%s" % e)
            return
        used = self.used_refl()
        if not used:
            messagebox.showerror("CIF to MPD", "No reflection is selected.")
            return
        path = filedialog.asksaveasfilename(initialdir=self.cfg.get("out_dir", default_materials_dir()), initialfile=name + ".mpd",
                                            defaultextension=".mpd", filetypes=[("MPD", "*.mpd")], title="Save .mpd file")
        if not path:
            return
        self.cfg["out_dir"] = os.path.dirname(path)
        save_cfg(self.cfg)
        try:
            skipped = core.write_mpd(path, os.path.splitext(os.path.basename(path))[0], P, [(r["hkl"], r["d"]) for r in used])
        except Exception as e:
            messagebox.showerror("CIF to MPD", "Writing failed:\n%s" % e)
            return
        msg = "Saved: %s\n%d reflections written." % (path, len(used) - skipped)
        if skipped:
            msg += "\n%d reflections with indices >= 10 were left out (the format allows single digits only)." % skipped
        messagebox.showinfo("CIF to MPD", msg)

    # ------------------------------------------------------------------ Spektrum
    def update_plot(self):
        ax = self.ax
        ax.clear()
        refl = self.used_refl()
        ed = self.mode.get() == "ED"
        try:
            if ed:
                tth = float(self.var_tth.get())
                x0, x1 = float(self.var_e0.get()), float(self.var_e1.get())
                lines = core.spectrum_lines(refl, "ED", tth=tth, xmin=x0, xmax=x1)
                ax.set_xlabel("E (keV)   (2theta = %g deg)" % tth)
            else:
                wl = RADIATIONS.get(self.var_rad.get())
                if wl is None:
                    wl = float(self.var_rad.get())
                x0, x1 = float(self.var_t0.get()), float(self.var_t1.get())
                lines = core.spectrum_lines(refl, "AD", wavelength=wl, xmin=x0, xmax=x1, lp=self.var_lp.get())
                ax.set_xlabel("2theta (deg)   (lambda = %.4f A)" % wl)
            fwhm = float(self.var_fwhm.get())
        except ValueError:
            ax.text(0.5, 0.5, "please check the numbers", transform=ax.transAxes, ha="center")
            self.canvas.draw()
            return
        ax.set_ylabel("relative intensity (%)")
        if not lines:
            ax.text(0.5, 0.5, "no reflections in this range" if refl else "no data", transform=ax.transAxes, ha="center")
            self.canvas.draw()
            return
        imax = max(l[1] for l in lines)
        xs = np.array([l[0] for l in lines])
        ys = np.array([100 * l[1] / imax for l in lines])
        ax.vlines(xs, 0, ys, colors="#c0392b", lw=1.4, label="calculated lines")
        if self.var_curve.get() and fwhm > 0:
            grid = np.linspace(x0, x1, 4000)
            cv = core.broaden(grid, lines, fwhm)
            cv = 100 * cv / cv.max() if cv.max() > 0 else cv
            ax.plot(grid, cv, color="#222", lw=1, label="broadened (FWHM %g)" % fwhm)
        if self.var_lab.get():
            for x, y, l in zip(xs, ys, lines):
                if y >= 15:
                    ax.annotate(l[3][0] + ("+" if len(l[3]) > 1 else ""), (x, y), xytext=(0, 3), textcoords="offset points",
                                rotation=90, ha="center", va="bottom", fontsize=8)
        ax.set_xlim(x0, x1)
        ax.set_ylim(0, 118)
        ax.grid(alpha=0.3)
        ax.legend(loc="upper right", fontsize=8)
        ax.set_title(os.path.basename(self.cif_path), fontsize=10)
        self.fig.tight_layout()
        self.canvas.draw()


def main():
    try:                                   # scharfe Darstellung auf Windows-Bildschirmen mit Skalierung
        import ctypes
        ctypes.windll.shcore.SetProcessDpiAwareness(1)
    except Exception:
        pass
    root = tk.Tk()
    app = App(root)
    args = [x for x in sys.argv[1:] if not x.startswith("--")]
    if args and os.path.isfile(args[0]):
        app.open_cif(args[0])
        app.calculate()
    if "--selftest" in sys.argv:             # fuer Tests der paketierten Version: Ergebnis in eine Textdatei schreiben
        out = sys.argv[sys.argv.index("--selftest") + 1]
        def done():
            try:
                with open(out, "w", encoding="utf-8") as f:
                    f.write("%s | %s | %s | %s | %s" % (app.var["elements"].get(), app.var["density"].get(), app.var["lattice"].get(), app.lbl_count.cget("text"), len(app.ax.lines) + len(app.ax.collections)))
                    app.fig.savefig(out + ".png", dpi=80)
                    if "--query" in sys.argv:               # Test der COD-Anbindung in der paketierten Version
                        res = cod_search.search(sys.argv[sys.argv.index("--query") + 1])
                        f.write(" | COD: %d entries, first %s" % (len(res), res[0]["id"] if res else "-"))
            except Exception as e:
                with open(out, "w", encoding="utf-8") as f:
                    f.write("ERROR %r" % e)
            root.destroy()
        root.after(1500, done)
    root.mainloop()


if __name__ == "__main__":
    main()
