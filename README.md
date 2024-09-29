# HeightProfileApp

**HeightProfileApp** is a MATLAB application designed to visualize and analyze height profile data from atomic force microscopy (AFM) images. This app enables users to load height data, plot surface profiles, perform baseline corrections, fit Gaussian models to detect peaks, and save results. 

---

**Important note**
- Ensure that the AFM surface profile data file is in `.txt` format.
- You can convert the AFM image (usually in `*.flt` format) to a *.txt file in [GWYDDION](http://gwyddion.net/). This can be simply done by opening the data in [GWYDDION](http://gwyddion.net/), then clicking the `save as` button to save in `*.txt` format. 
While saving, ensure you have unclicked all the labels in the **EXPORT FUNCTION** tab (the tab pops while saving the file in `*.txt` format).

---

## Features
- **Load Height Data**: Import AFM raw data in `.txt` format. (here it is `CNC-A250-2.5min-2.SIG_TOPO_FRW.txt`)
- **Visualize Surface**: Display 3D surface plots of the height data.
- **Profile Extraction**: Extract and visualize height profiles based on user-defined coordinates.
- **Baseline Correction**: Correct the baseline of the extracted profiles.
- **Gaussian Fitting**: Fit Gaussian models to peaks in the corrected profile.
- **Results Table**: Displays base width = 2xFWHM (Full Width at Half Maximum) and aspect ratio data in a table format.
- **Save Results**: Export results to `.*CSV` files for further analysis.

## Requirements

- MATLAB (R2019a or later recommended)
- MATLAB App Designer (included with MATLAB)
- Basic knowledge of MATLAB and data visualization techniques


## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/hisaylama/HeightProfileApp.git
   ```


2. **Open the App in MATLAB**:
   Navigate to the cloned directory in MATLAB, and open the `HeightProfileApp.m` file.

3. **Run the App**:
   Execute the app by running the following command in the MATLAB Command Window:
   ```matlab
   app = HeightProfileApp;
   ```

## Usage

1. **Load AFM Data**: Click the "Load data" button to import a height data file in `.txt` format.
2. **Set Coordinates**: Input the X1, Y1, X2, and Y2 coordinates in the respective fields to define the line profile for extraction.
3. **Plot Line Location**: Click "Line loc" to visualize the selected line location on the height surface.
4. **Extract and Plot Profile**: Click the "Plot profile" button to extract and visualize the height profile along the specified line.
5. **Baseline Correction**: Click "Baseline correction" to perform baseline adjustment on the extracted profile.
6. **Gaussian Fit**: Click "Gaussian fit" to fit Gaussian models to the corrected profile peaks and display the results.
7. **View Results**: The results table displays the FWHM and aspect ratios for the fitted peaks.
8. **Save Results**: Click "Save Results" to export the results table to a CSV file.
9. **Note**: Gaussian fitting and the results tables are applicable only for the sinusoid-type height profile. Otherwise, stop after you obtain the height profile.

## Example

Here’s a brief example to demonstrate how to use the app:
1. Load your height data using the "Load data" button.
2. Define the line profile coordinates in the X1, Y1, X2, and Y2 fields.
3. Use the buttons to visualize, correct, and analyze the height data.
4. Save the analysis results in `.csv` format for further analysis.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request for any changes or enhancements you would like to suggest.

## Output 
Here is a snapshot of the user interface of the HeightVisualization app.
![HeightVisualisatioApp_FinalOutput](https://github.com/user-attachments/assets/a588fdb4-2f92-4239-87ef-a7377fecc0e7)

## Acknowledgements

- This app was developed as part of research work involving atomic force microscopy and data analysis techniques.
- Thanks to the MATLAB community for providing extensive resources and support.

---

