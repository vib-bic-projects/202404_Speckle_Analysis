# 202404_Speckle_Analysis
FIJI and Qupath pipeline to quantify speckle size and number. 

## (Optional) Speckle Enhancement (FIJI)
- 202404_Speckle_Analysis\scripts\1_fiji\MecP2_analysis_script_preprocessingforQupath.ijm
## 1. Qupath
### ROI drawing
### Particle detection using Stardist
### (Optional) Train an object classifier to filter out false detections
### Run Groovy Script and export measurements (Qupath)
- 202404_Speckle_Analysis\scripts\2_qupath\Speckle_analysis.groovy
## 2. Run python script for analyzing the speckles (Google Collab)
- 202404_Speckle_Analysis\scripts\3_python\Laura_speckle_analysis_script.ipynb
## 3. Visualize Data (Prism)
