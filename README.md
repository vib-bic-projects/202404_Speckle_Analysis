# 202404_Speckle_Analysis
FIJI and Qupath pipeline to quantify speckle size and number.

## (Optional) Speckle Enhancement (FIJI)
- Install the CLIJ2 plug-in. (https://clij.github.io/)
- Drag and drop "202404_Speckle_Analysis\scripts\1_fiji\MecP2_analysis_script_preprocessingforQupath.ijm" to FIJI.
- Click "Run"
- Set the proper parameters in the user interface:

![image](https://github.com/user-attachments/assets/0995d6e1-c327-4003-8923-81076b0bd385)

**File directory:** File path location

**What working station are you using?:** Here you should select the computer you are using. This is linked to the GPU name of that system

**Channel containing the blob marker:** Here you should give the channel of the marker that will be enhanced and should be a number 

**File suffix:** Here select the image file format. Should be .czi or .tif

## 1. Qupath
### Creating a project
1. Open Qupath
2. File>Project>Create a project in an empty folder
3. Drag your images into Qupath
   
### ROI drawing
4. Use any of the tools to draw your region of interest (ROI) in every image
   
### Particle detection using Stardist
5. Drag and drop to Qupath 202404_Speckle_Analysis\scripts\2_qupath\Speckle_segmentation_noclassifier.groovy
6. Assign the name of the channel that will be used for the speckle analysis

![image](https://github.com/user-attachments/assets/38cf8fd2-57e6-48fd-827e-5ddfa8b49d14)

7. Assign the name of the channels in the image

![image](https://github.com/user-attachments/assets/5559c199-dc03-4863-ae4d-63bd88e5554a)

### (Optional) Train an object classifier to filter out false detections
If the previous segmentation tool is not enough to accurately segment the speckles an object classifier can be trained. For this you can use any of the strategies available in Qupath https://qupath.readthedocs.io/en/stable/docs/tutorials/cell_classification.html

8. Train the object classifier with ground truth annotations.

![image](https://github.com/user-attachments/assets/76b4645a-95e1-4162-80f4-72a543be4ab8)

9. Train the object classifier and use the name as parameter in the groovy script of the next step.

### Run Groovy Script and export measurements (Qupath)
10. Drag and drop into Qupath 202404_Speckle_Analysis\scripts\2_qupath\Speckle_analysis.groovy
11. Set the parameter 1, 2, and 3.
// Get user input
param1 = "MecP2_enhanced" //What channel name should be used for speckle segmentation? (e.g. MecP2_enhanced)
param2 = "Yes" //Was an object classifier trained for the speckles? Answer with Yes or No)
param3 = "Speckle_classifier" //What is the name of the classifier?(e.g. Speckle_classifier)

![image](https://github.com/user-attachments/assets/6febf88d-978a-48e2-a6ca-99adca99fd87)

12. Set the channel names again as in step 6.

![image](https://github.com/user-attachments/assets/1bfc96e6-58b5-4e01-bdb2-dbac943e2179)

13. Run the script in the whole project by going to the Script Editor>Run>Run for project

14. When this step is finished export the results by clicking in Measure>Export Measurements

![image](https://github.com/user-attachments/assets/86e97520-ca34-41ec-94af-a40e033cbbc2)

- Be sure to select all of the images you want to include
- Export type should be Detections
- Separator: Comma (.csv)
- Columns to include (Image, Classification and Area)

## 2. Run python script for analyzing the speckles (Google Collab)
**Run the Script in Google Colab**
You can easily run this script in Google Colab by clicking the link below:

[Open in Google Colab](https://colab.research.google.com/github/vib-bic-projects/202404_Speckle_Analysis\scripts\3_python\Laura_speckle_analysis_script.ipynb)

15. Import the .csv measurements file from Qupath to the google collab notebook

![image](https://github.com/user-attachments/assets/0ad485f8-67d4-491b-987a-7e9f0e3d9474)

16. Set the parameters

![image](https://github.com/user-attachments/assets/75f68364-1d28-4fc1-b772-cc6f549441c1)

**output_path:** Here you should write the output path between ''. If you want it to save the output excel file in the same workplace as the uploaded .csv just use '/content'
**qupath_measurements:** Here you should write the path to the qupath measurement csv. You can get the path by clicking on the three dotes next to the file and click Copy path as shown below.

![image](https://github.com/user-attachments/assets/2e22892f-e506-4556-8389-cab1a64b6972)

**description_file:** To add to the csv information on the animal and region that is being analyzed per image, a description file with the exact same format and column names as the template: 202404_Speckle_Analysis\scripts\description_file_example.csv

**object_classifier:** Here you should write the name of the positively classified cells between brackets (e.g. 'MecP2_enhanced'). If it is anything other than 'None' this will be used to filter speckles by classification.

## 3. Visualize Data (Prism)
