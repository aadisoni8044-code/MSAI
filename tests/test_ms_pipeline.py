"""
test_ms_pipeline.py

Unit tests verifying pyOpenMS MSExperiment handling, DataFrame formatting,
and peak-picking processing parameters within ms_pipeline.py.
"""

import os
import math
import pytest
import pandas as pd
import pyopenms as ms

import ms_pipeline

@pytest.fixture
def sample_experiment():
    """
    Constructs a simple simulated MSExperiment with a Gaussian chromatographic profile.
    """
    exp = ms.MSExperiment()
    # Create 10 spectra simulating a chromatographic peak over time
    for r in range(10):
        rt = float(r)
        s = ms.MSSpectrum()
        f = math.exp(-((rt - 5.0)**2) / 4.0)

        # simulated m/z peaks
        mzs = [500.0, 501.0, 502.0]
        ints = [10000.0 * f, 5000.0 * f, 2000.0 * f]

        s.set_peaks((mzs, ints))
        s.setRT(rt)
        s.setMSLevel(1)
        exp.addSpectrum(s)

    exp.updateRanges()
    return exp

def test_load_experiment_missing_file():
    """
    Verifies that loading a non-existent file path correctly raises a FileNotFoundError.
    """
    with pytest.raises(FileNotFoundError):
        ms_pipeline.load_experiment("non_existent_spectrometry_file.mzML")

def test_load_experiment_unsupported_format(tmp_path):
    """
    Verifies that passing an unsupported file format raises a ValueError.
    """
    txt_file = tmp_path / "data.txt"
    txt_file.write_text("not raw ms data")

    with pytest.raises(ValueError):
        ms_pipeline.load_experiment(str(txt_file))

def test_pick_peaks_already_centroided(sample_experiment):
    """
    Verifies that if spectra are already marked as centroid, peak picking is skipped.
    """
    # Force spectra types to CENTROID
    for s in sample_experiment.getSpectra():
        s.setType(ms.SpectrumSettings.SpectrumType.CENTROID)

    res = ms_pipeline.pick_peaks(sample_experiment, signal_to_noise=1.5)
    assert res.size() == sample_experiment.size()

def test_find_features_creates_map(sample_experiment):
    """
    Verifies that running find_features returns a pyOpenMS FeatureMap.
    """
    options = {
        "ff_min_spectra": 3,
        "ff_charge_low": 1,
        "ff_charge_high": 2,
        "ff_mz_tolerance": 0.1,
        "ff_min_score": 0.1
    }
    fmap = ms_pipeline.find_features(sample_experiment, options)
    assert isinstance(fmap, ms.FeatureMap)

def test_create_feature_dataframe_empty():
    """
    Verifies that an empty FeatureMap maps to an empty pandas DataFrame with proper columns.
    """
    fmap = ms.FeatureMap()
    df = ms_pipeline.create_feature_dataframe(fmap)
    assert isinstance(df, pd.DataFrame)
    assert df.empty
    assert list(df.columns) == ["Feature ID", "m/z", "RT (s)", "RT (min)", "Intensity", "Charge", "Quality"]

def test_create_feature_dataframe_populated():
    """
    Verifies that FeatureMap records convert to expected DataFrame columns and types.
    """
    fmap = ms.FeatureMap()
    f1 = ms.Feature()
    f1.setUniqueId(101)
    f1.setMZ(500.25)
    f1.setRT(60.0)
    f1.setIntensity(50000.0)
    f1.setCharge(2)
    f1.setOverallQuality(0.85)
    fmap.push_back(f1)

    df = ms_pipeline.create_feature_dataframe(fmap)
    assert len(df) == 1
    assert df.loc[0, "Feature ID"] == 101
    assert df.loc[0, "m/z"] == 500.25
    assert df.loc[0, "RT (s)"] == 60.0
    assert df.loc[0, "RT (min)"] == 1.0
    assert df.loc[0, "Intensity"] == 50000.0
    assert df.loc[0, "Charge"] == 2
    assert pytest.approx(df.loc[0, "Quality"]) == 0.85
