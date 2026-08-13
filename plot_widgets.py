"""
plot_widgets.py

Matplotlib plots integrated in PyQt widgets. Contains spectrum peak intensity,
chromatogram profiles (TIC), and feature markers over chromatographic runs.
"""

import logging
from typing import Optional
import numpy as np
from PyQt5.QtWidgets import QWidget, QVBoxLayout
import matplotlib
matplotlib.use("Qt5Agg")
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg, NavigationToolbar2QT
from matplotlib.figure import Figure

import pyopenms as ms

logger = logging.getLogger("OpenMS Analyzer.plot_widgets")

class BasePlotWidget(QWidget):
    """
    Subclassable QWidget containing an embedded Matplotlib figure, canvas,
    and interactive toolbar.
    """
    def __init__(self, parent: Optional[QWidget] = None):
        super().__init__(parent)
        self.figure = Figure(tight_layout=True)
        self.canvas = FigureCanvasQTAgg(self.figure)
        self.ax = self.figure.add_subplot(111)
        self.toolbar = NavigationToolbar2QT(self.canvas, self)

        layout = QVBoxLayout(self)
        layout.addWidget(self.toolbar)
        layout.addWidget(self.canvas)
        self.setLayout(layout)

    def clear(self):
        """
        Clears the current axes and re-draws an empty canvas.
        """
        self.ax.clear()
        self.canvas.draw()


class SpectrumPlotWidget(BasePlotWidget):
    """
    Plots individual mass spectrum profiles (m/z vs. intensity)
    """
    def plot_spectrum(self, spectrum: ms.MSSpectrum, title: str = "Mass Spectrum"):
        """
        Plots mz vs intensity arrays from an MSSpectrum.

        Args:
            spectrum (ms.MSSpectrum): Spectrum containing peak coordinates.
            title (str): Title of the plot.
        """
        self.ax.clear()

        mz, intensities = spectrum.get_peaks()
        if len(mz) == 0:
            self.ax.text(0.5, 0.5, "No peaks present in this spectrum",
                         ha="center", va="center", transform=self.ax.transAxes)
            self.ax.set_title(title)
            self.canvas.draw()
            return

        # Plot peaks as vertical lines (standard stem representation or bar-like peaks)
        self.ax.vlines(mz, 0, intensities, colors="b", linewidth=1.2, label="Peaks")

        # Highlight top peak
        max_idx = intensities.argmax()
        self.ax.annotate(f"m/z {mz[max_idx]:.4f}\nInt {intensities[max_idx]:.1e}",
                         xy=(mz[max_idx], intensities[max_idx]),
                         xytext=(10, 10),
                         textcoords="offset points",
                         arrowprops=dict(arrowstyle="->", color="red"))

        self.ax.set_xlabel("m/z")
        self.ax.set_ylabel("Intensity")
        self.ax.set_title(title)
        self.ax.grid(True, alpha=0.3)
        self.canvas.draw()


class ChromatogramPlotWidget(BasePlotWidget):
    """
    Plots Retention Time vs Total Ion Current (TIC) chromatograms.
    """
    def plot_tic(self, exp: ms.MSExperiment, title: str = "Total Ion Chromatogram (TIC)"):
        """
        Reconstructs the chromatogram from all MS1 level spectra.

        Args:
            exp (ms.MSExperiment): Spectrum container.
            title (str): Title of the plot.
        """
        self.ax.clear()

        rt_values = []
        tic_values = []

        for spec in exp.getSpectra():
            if spec.getMSLevel() == 1:
                rt_values.append(spec.getRT())
                # Sum intensities to approximate TIC if not set
                intensities = spec.get_intensity_array()
                tic_values.append(intensities.sum() if len(intensities) > 0 else 0.0)

        if not rt_values:
            self.ax.text(0.5, 0.5, "No MS1 level spectra found to compute TIC",
                         ha="center", va="center", transform=self.ax.transAxes)
            self.ax.set_title(title)
            self.canvas.draw()
            return

        # Sort values by RT to render cleanly
        sorted_indices = np.argsort(rt_values)
        rts = np.array(rt_values)[sorted_indices]
        tics = np.array(tic_values)[sorted_indices]

        # Render line plot
        self.ax.plot(rts / 60.0, tics, "g-", linewidth=1.5, label="TIC")
        self.ax.set_xlabel("Retention Time (min)")
        self.ax.set_ylabel("Total Ion Current")
        self.ax.set_title(title)
        self.ax.grid(True, alpha=0.3)
        self.canvas.draw()


class FeatureOverlayPlotWidget(BasePlotWidget):
    """
    Plots chromatogram and overlays 2D scatter dots or convex bounding hulls
    showing detected feature regions in the RT dimension.
    """
    def plot_features(self, exp: ms.MSExperiment, fmap: ms.FeatureMap, title: str = "Features Overlaid on TIC"):
        """
        Plots TIC and overlays points corresponding to detected features.

        Args:
            exp (ms.MSExperiment): Spectrum dataset.
            fmap (ms.FeatureMap): Detected feature list.
            title (str): Title of the plot.
        """
        self.ax.clear()

        # 1. Plot the TIC
        rt_values = []
        tic_values = []
        for spec in exp.getSpectra():
            if spec.getMSLevel() == 1:
                rt_values.append(spec.getRT())
                ints = spec.get_intensity_array()
                tic_values.append(ints.sum() if len(ints) > 0 else 0.0)

        if rt_values:
            sorted_indices = np.argsort(rt_values)
            rts = np.array(rt_values)[sorted_indices] / 60.0
            tics = np.array(tic_values)[sorted_indices]
            self.ax.plot(rts, tics, color="gray", alpha=0.5, linewidth=1.0, label="TIC")

        # 2. Overlay Features
        if fmap.size() == 0:
            self.ax.text(0.5, 0.5, "No features to display",
                         ha="center", va="center", transform=self.ax.transAxes)
            self.ax.set_title(title)
            self.canvas.draw()
            return

        feat_rts = []
        feat_ints = []
        feat_labels = []

        for idx, f in enumerate(fmap):
            # Feature RT is typically in seconds; convert to minutes
            feat_rts.append(f.getRT() / 60.0)
            feat_ints.append(f.getIntensity())
            feat_labels.append(f"F{idx} (m/z:{f.getMZ():.2f})")

        # Scatter plot detected features
        scatter = self.ax.scatter(feat_rts, feat_ints, c="red", marker="x", s=60,
                                  zorder=5, label="Detected Features")

        # Add a few labels for the highest intensity features to avoid cluttering
        sorted_indices = np.argsort(feat_ints)[::-1]
        for i in sorted_indices[:10]: # label top 10 features
            if i < len(feat_rts):
                self.ax.annotate(feat_labels[i],
                                 xy=(feat_rts[i], feat_ints[i]),
                                 xytext=(5, 5),
                                 textcoords="offset points",
                                 fontsize=8,
                                 alpha=0.8)

        self.ax.set_xlabel("Retention Time (min)")
        self.ax.set_ylabel("Intensity")
        self.ax.set_title(title)
        self.ax.legend(loc="upper right")
        self.ax.grid(True, alpha=0.3)
        self.canvas.draw()
