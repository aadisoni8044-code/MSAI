"""
ms_pipeline.py

Core pyOpenMS logic for loading, centroiding, and feature finding.
Includes background process mechanics with progress updates.
"""

import os
import time
import logging
from typing import Callable, Dict, Any, Optional
import pandas as pd
import pyopenms as ms

logger = logging.getLogger("OpenMS Analyzer.ms_pipeline")

def load_experiment(path: str) -> ms.MSExperiment:
    """
    Loads an mzML or mzXML file into an MSExperiment.

    Args:
        path (str): The local path to the raw mass spectrometry data file.

    Returns:
        ms.MSExperiment: Loaded experiment object.
    """
    if not os.path.exists(path):
        raise FileNotFoundError(f"Raw data file not found: {path}")

    exp = ms.MSExperiment()
    ext = os.path.splitext(path)[1].lower()

    if ext == ".mzml":
        ms.MzMLFile().load(path, exp)
    elif ext in (".mzxml", ".xml"):
        ms.MzXMLFile().load(path, exp)
    else:
        # Fallback to try loading anyway or raise
        try:
            ms.MzMLFile().load(path, exp)
        except Exception:
            try:
                ms.MzXMLFile().load(path, exp)
            except Exception:
                raise ValueError(f"Unsupported or unreadable file format: {ext}")

    return exp

def pick_peaks(exp: ms.MSExperiment, signal_to_noise: float = 1.0) -> ms.MSExperiment:
    """
    Applies PeakPickerHiRes to centroid the profile spectrum data.
    If the spectra are already centroided, returns a copy of the input.

    Args:
        exp (ms.MSExperiment): Input experiment.
        signal_to_noise (float): Signal-to-noise ratio threshold.

    Returns:
        ms.MSExperiment: Centroided experiment.
    """
    # Check if all spectra are already centroided
    all_centroided = True
    spectra = exp.getSpectra()
    if len(spectra) > 0:
        for s in spectra:
            if s.getType() != ms.SpectrumSettings.SpectrumType.CENTROID:
                all_centroided = False
                break

    if all_centroided:
        logger.info("Spectra already centroided. Skipping peak picking.")
        return exp

    logger.info("Running PeakPickerHiRes centroiding pipeline...")
    picked_exp = ms.MSExperiment()

    picker = ms.PeakPickerHiRes()
    params = picker.getDefaults()
    # set signal to noise if applicable
    params.setValue("signal_to_noise_threshold", float(signal_to_noise))
    picker.setParameters(params)

    picker.pickExperiment(exp, picked_exp, True)
    return picked_exp

def find_features(exp: ms.MSExperiment, options: Dict[str, Any]) -> ms.FeatureMap:
    """
    Runs FeatureFinderAlgorithmPicked to locate feature chromatographic peaks.

    Args:
        exp (ms.MSExperiment): Picked/centroided MSExperiment.
        options (Dict[str, Any]): Feature finder settings.

    Returns:
        ms.FeatureMap: Detected feature map.
    """
    # Ensure ranges are updated (required by some FeatureFinder modules)
    exp.updateRanges()

    fmap = ms.FeatureMap()
    seeds = ms.FeatureMap()

    ff = ms.FeatureFinderAlgorithmPicked()
    params = ff.getDefaults()

    # Configure custom parameters from option dictionary
    if "ff_min_spectra" in options:
        params.setValue("mass_trace:min_spectra", int(options["ff_min_spectra"]))
    if "ff_charge_low" in options:
        params.setValue("isotopic_pattern:charge_low", int(options["ff_charge_low"]))
    if "ff_charge_high" in options:
        params.setValue("isotopic_pattern:charge_high", int(options["ff_charge_high"]))
    if "ff_mz_tolerance" in options:
        params.setValue("mass_trace:mz_tolerance", float(options["ff_mz_tolerance"]))
        params.setValue("isotopic_pattern:mz_tolerance", float(options["ff_mz_tolerance"]))
    if "ff_min_score" in options:
        params.setValue("seed:min_score", float(options["ff_min_score"]))

    ff.run(exp, fmap, params, seeds)
    return fmap

def create_feature_dataframe(fmap: ms.FeatureMap) -> pd.DataFrame:
    """
    Converts pyOpenMS FeatureMap into a pandas DataFrame.

    Args:
        fmap (ms.FeatureMap): Detected features.

    Returns:
        pd.DataFrame: Structured table containing:
                      ['Feature ID', 'm/z', 'RT (s)', 'RT (min)', 'Intensity', 'Charge', 'Quality']
    """
    data = []
    for idx, f in enumerate(fmap):
        data.append({
            "Feature ID": f.getUniqueId() if f.hasValidUniqueId() else idx,
            "m/z": f.getMZ(),
            "RT (s)": f.getRT(),
            "RT (min)": f.getRT() / 60.0,
            "Intensity": f.getIntensity(),
            "Charge": f.getCharge(),
            "Quality": f.getOverallQuality()
        })

    if not data:
        # Return empty dataframe with columns
        return pd.DataFrame(columns=["Feature ID", "m/z", "RT (s)", "RT (min)", "Intensity", "Charge", "Quality"])

    return pd.DataFrame(data)

def run_full_pipeline(
    path: str,
    options: Dict[str, Any],
    progress_callback: Optional[Callable[[int, str], None]] = None
) -> Dict[str, Any]:
    """
    Orchestrates the entire MS pipeline processing steps.

    Args:
        path (str): Filepath of the raw data.
        options (Dict[str, Any]): Dictionary of pipeline parameters.
        progress_callback (Optional[Callable[[int, str], None]]): Callback reporting percent and message.

    Returns:
        Dict[str, Any]: Pipeline execution result object.
    """
    start_time = time.time()

    def report_progress(percent: int, message: str):
        logger.info(f"[{percent}%] {message}")
        if progress_callback:
            try:
                progress_callback(percent, message)
            except Exception as e:
                logger.warning(f"Failed to execute progress callback: {e}")

    report_progress(5, "Loading raw mass spec file...")
    exp = load_experiment(path)

    total_spectra = exp.size()
    report_progress(30, f"Successfully loaded {total_spectra} spectra.")

    # Optional peak picking
    peak_picking_enabled = options.get("peak_picking_enabled", True)
    if peak_picking_enabled:
        report_progress(40, "Picking peaks/centroiding profile data...")
        sn = options.get("peak_picking_signal_to_noise", 1.0)
        processed_exp = pick_peaks(exp, signal_to_noise=sn)
        report_progress(65, "Peak picking complete.")
    else:
        report_progress(60, "Peak picking disabled. Using raw/existing spectrum data.")
        processed_exp = exp

    report_progress(70, "Finding chromatographic features...")
    fmap = find_features(processed_exp, options)
    num_features = fmap.size()
    report_progress(90, f"Feature detection complete. Found {num_features} features.")

    report_progress(95, "Formatting results table...")
    df = create_feature_dataframe(fmap)

    elapsed = time.time() - start_time
    report_progress(100, f"Pipeline execution completed in {elapsed:.2f} seconds.")

    # Gather statistics
    stats = {
        "file_name": os.path.basename(path),
        "total_spectra": total_spectra,
        "features_detected": num_features,
        "processing_time_s": elapsed,
        "pipeline_settings": options
    }

    return {
        "experiment": processed_exp,
        "feature_map": fmap,
        "dataframe": df,
        "stats": stats
    }
