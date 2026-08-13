"""
report_generator.py

Aggregates execution output into a neat, exportable folder structure.
Writes results to a CSV file, saves generated PNG plots, and creates a
comprehensive plain-text/Markdown processing summary report.
"""

import os
import shutil
import tempfile
import logging
from typing import Dict, Any, List
import pandas as pd

logger = logging.getLogger("OpenMS Analyzer.report_generator")

def generate_summary_report(stats: Dict[str, Any]) -> str:
    """
    Creates a detailed Markdown/plain text summary of the processing run.
    """
    settings = stats.get("pipeline_settings", {})

    report = []
    report.append("# OpenMS Analyzer Run Report")
    report.append("==============================")
    report.append(f"Processed File:   {stats.get('file_name', 'Unknown')}")
    report.append(f"Spectra Loaded:   {stats.get('total_spectra', 0)}")
    report.append(f"Features Found:   {stats.get('features_detected', 0)}")
    report.append(f"Processing Time:  {stats.get('processing_time_s', 0.0):.2f} seconds")
    report.append("")
    report.append("## Pipeline Configuration Settings")
    report.append("---------------------------------")
    for key, value in settings.items():
        report.append(f"- {key}: {value}")
    report.append("")
    report.append("Generated with OpenMS Analyzer.")

    return "\n".join(report)

def build_export_bundle(
    df: pd.DataFrame,
    stats: Dict[str, Any],
    plot_callbacks: List[callable] = None
) -> str:
    """
    Creates a temporary folder containing the CSV feature table, Matplotlib plot
    images, and the text report. Returns the path to this folder.

    Args:
        df (pd.DataFrame): Calculated feature table.
        stats (Dict[str, Any]): Meta stats about execution.
        plot_callbacks (List[callable]): Functions that accept a folder path to save plots as PNG.

    Returns:
        str: Absolute path to the temporary export folder.
    """
    # Create temporary directory
    temp_dir = tempfile.mkdtemp(prefix="openms_analyzer_bundle_")

    # 1. Save CSV Feature Table
    csv_path = os.path.join(temp_dir, "detected_features.csv")
    df.to_csv(csv_path, index=False)
    logger.info(f"Saved export CSV to {csv_path}")

    # 2. Save PNG plots if callback triggers exist
    if plot_callbacks:
        for idx, cb in enumerate(plot_callbacks):
            try:
                cb(temp_dir)
            except Exception as e:
                logger.error(f"Failed to generate and save plot {idx}: {e}")

    # 3. Save Markdown/Text Summary Report
    summary_text = generate_summary_report(stats)
    summary_path = os.path.join(temp_dir, "processing_summary.txt")
    with open(summary_path, "w") as f:
        f.write(summary_text)
    logger.info(f"Saved summary report to {summary_path}")

    return temp_dir
