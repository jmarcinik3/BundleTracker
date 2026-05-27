[![DOI](https://zenodo.org/badge/753794151.svg)](https://doi.org/10.5281/zenodo.14262468)

# Installation
Downloading
1. Download and install MATLAB 2023b (only this specific version, not MATLAB 2024a or newer).
2. Download and unzip the content from this repository. You may place this content anywhere on your computer.

Executing
1. Open MATLAB 2023b.
2. Navigate to the path with the *.prj file (MATLAB project file) from this repository. There exists only one project file included in this repository.
4. Open this project file within MATLAB. This adds the dependent project files into MATLAB's path environment, for the current session. This project file will need to be reopened after MATLAB is closed.
5. Open the tracking GUI with the following command in MATLAB's terminal: TrackingLinker(TrackingGui)

Demos
1. Open the *.mlx files (from within MATLAB) in the "Demos" folder for tutorials.

Dependencies
- MATLAB 2023b (exactly this version, neither earlier nor newer)
- Computer Vision Toolbox
- Curve Fitting Toolbox
- Econometrics Toolbox
- Image Processing Toolbox
- Optimization Toolbox
- Signal Processing Toolbox
- Statistic and Machine Learning Toolbox

See the included PDF, which details all calculations used throughout tracking.




# ProbeCalibrator
Estimate the stiffness and drag of your probe undergoing Brownian motion using the ProbeCalibrator GUI. To determine the stiffness and drag of a probe, the software fits Equation (S26) from [Bormuth et al. 2014](https://www.pnas.org/doi/full/10.1073/pnas.1402556111) to the power spectrum of the probe's Brownian motion. To have units for the stiffness of uN/m and for the drag coefficient of nN.s/m (as displayed in the ProbeCalibrator GUI), use nm/px for the length/px input in the main window.
