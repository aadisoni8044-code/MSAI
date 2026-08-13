# OpenMS Analyzer

OpenMS Analyzer is a desktop application written in Python using **PyQt5** (GUI), **pyOpenMS** (mass spectrometry data processing), and the **Google Drive API** (for downloading raw datasets and uploading processing results/reports).

This application was designed to allow scientists to import raw files (.mzML or .mzXML), pick centroid peaks, discover feature coordinates over chromatographic space, visually interact with spectral figures, and upload structured tabular and visual summaries directly into their Google Drive accounts.

## Core Features
1. **Interactive Processing Configuration**: Tweak peak-picking thresholds and FeatureFinder options via an intuitive side-panel layout.
2. **Dynamic Plotting Elements**: Interactive zoomable plots featuring:
   - **Mass Spectrum View**: Plots m/z vs intensity with highest peak labels.
   - **Chromatogram View**: Approximates the Total Ion Current (TIC) trace.
   - **Feature Overlay**: Visualizes peak coordinates over retention time.
3. **Sortable Feature Table**: Interact, view, and sort extracted features in a tabular presentation.
4. **Asynchronous Processing**: Long-running computational processes and cloud downloads/uploads occur in background threads (`QThread`) keeping the GUI responsive.
5. **Google Drive Integration**: Import files, create dedicated results folders, and save CSV data tables, graphical PNG figures, and text summaries inside Google Drive.

---

## File Structure
The project is organized cleanly into modular files:
- **`main.py`**: Launches the main application and manages UI transitions, threads, and custom logging targets.
- **`ui_main_window.py`**: Declares layout structures, parameters boxes, plotting widgets, and action menus.
- **`ms_pipeline.py`**: Standard processing workflow executing peak picking and feature detection.
- **`drive_client.py`**: Connection client for Google Drive API OAuth verification, downloading, and uploading.
- **`drive_picker_dialog.py`**: Searchable Drive selection dialog.
- **`plot_widgets.py`**: Matplotlib embedded charts (Spectrum, TIC, and Overlaid features).
- **`feature_table_model.py`**: Custom sortable table model.
- **`report_generator.py`**: Aggregates output files into a temporary export bundle directory.
- **`config.py`**: Default constants and logging setups.
- **`requirements.txt`**: Pin-point installation criteria.

---

## Installation & Setup

### Prerequisites
- Python 3.11 or later

### Local setup
Create a virtual environment and install dependencies:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Google Cloud Console (Drive API Credentials)
To use the Google Drive features, you must supply OAuth Client Credentials:
1. Navigate to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project.
3. Enable the **Google Drive API** in your project.
4. Configure your **OAuth Consent Screen** (specify "External" user type and add your email; add the scope `https://www.googleapis.com/auth/drive.file`).
5. Go to **Credentials**, select **Create Credentials** -> **OAuth client ID**, and select **Desktop app** as the application type.
6. Click download to fetch the client credentials JSON file, rename it to `credentials.json`, and place it in the root directory of this project.

On the initial execution of a Google Drive action, a web browser window will launch requesting permissions to access and create files in your Drive. After giving permission, the token will be cached as `token.json` so you do not have to log in on subsequent executions.

---

## Usage

Run the app using python:
```bash
python main.py
```

### Testing and Sample Data
To test the pipeline processing, you can download small public domain test files (e.g., from OpenMS or PRIDE datasets) or use the simulated tests folder:
1. Open the app.
2. Select **File -> Open Local File...** or download a file from Google Drive using **File -> Open from Google Drive...**.
3. Tune processing options on the left-hand settings box.
4. Click **🚀 Run Processing Pipeline**.
5. Analyze tables and plots under each of the tabs.
6. Click **File -> Export Results to Drive...** to upload your plots, feature lists, and text report directly to Google Drive.

---

## Running Unit Tests
A suite of tests has been created to test core computational modules of the pipeline:
```bash
pytest -v
```
