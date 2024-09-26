# HeightProfileApp

**HeightProfileApp** is a MATLAB application designed for visualizing and analyzing height profile data from atomic force microscopy (AFM) images. This app enables users to load height data, plot surface profiles, perform baseline corrections, fit Gaussian models to detected peaks, and save results.

## Features

- **Load Height Data**: Import height data from text files.
- **Visualize Surface**: Display 3D surface plots of the height data.
- **Profile Extraction**: Extract and visualize height profiles based on user-defined coordinates.
- **Baseline Correction**: Correct the baseline of the extracted profiles.
- **Gaussian Fitting**: Fit Gaussian models to peaks in the corrected profile.
- **Results Table**: Display FWHM (Full Width at Half Maximum) and aspect ratio data in a table format.
- **Save Results**: Export results to CSV files for further analysis.

## Requirements

- MATLAB (R2019a or later recommended)
- MATLAB App Designer (included with MATLAB)
- Basic knowledge of MATLAB and data visualization techniques

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/hisaylama/HeightProfileApp.git
   ```
   Replace `hisaylama` with your actual GitHub username.

2. **Open the App in MATLAB**:
   Navigate to the cloned directory in MATLAB, and open the `HeightProfileApp.m` file.

3. **Run the App**:
   Execute the app by running the following command in the MATLAB Command Window:
   ```matlab
   app = HeightProfileApp;
   ```

## Usage

1. **Load Data**: Click the "Load data" button to import a height data file in `.txt` format.
2. **Set Coordinates**: Input the X1, Y1, X2, and Y2 coordinates in the respective fields to define the line profile for extraction.
3. **Plot Line Location**: Click "Line loc" to visualize the selected line location on the height surface.
4. **Extract and Plot Profile**: Click the "Plot profile" button to extract and visualize the height profile along the specified line.
5. **Baseline Correction**: Click "Baseline correction" to perform baseline adjustment on the extracted profile.
6. **Gaussian Fit**: Click "Gaussian fit" to fit Gaussian models to the corrected profile peaks and display the results.
7. **View Results**: The results table displays the FWHM and aspect ratios for the fitted peaks.
8. **Save Results**: Click "Save Results" to export the results table to a CSV file.

## Example

Here’s a brief example to demonstrate how to use the app:

1. Load your height data using the "Load data" button.
2. Define the line profile coordinates in the X1, Y1, X2, and Y2 fields.
3. Use the buttons to visualize, correct, and analyze the height data.
4. Save the analysis results for further reference.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request for any changes or enhancements you would like to suggest.

## Acknowledgments

- This app was developed as part of research work involving atomic force microscopy and data analysis techniques.
- Thanks to the MATLAB community for providing extensive resources and support.

---

Feel free to modify any section or add more details that you think might be relevant for users of your application.
