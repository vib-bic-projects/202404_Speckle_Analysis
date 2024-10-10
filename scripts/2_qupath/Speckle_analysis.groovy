import javax.swing.JOptionPane
import qupath.ext.stardist.StarDist2D
import qupath.lib.scripting.QP

// Get user input
param1 = "MecP2_enhanced" //What channel name should be used for speckle segmentation? (e.g. MecP2_enhanced)
param2 = "Yes" //Was an object classifier trained for the speckles? Answer with Yes or No)
param3 = "Speckle_classifier" //What is the name of the classifier?(e.g. Speckle_classifier)

// Get the current project
def project = getProject()

// IMPORTANT! Replace this with the path to your StarDist model
// that takes a single channel as input (e.g. dsb2018_heavy_augment.pb)
// You can find some at https://github.com/qupath/models
// (Check credit & reuse info before downloading)
def modelPath = "C:/Users/u0119446/QuPath/v0.5/Stardist/dsb2018_heavy_augment.pb" //Change the path to the proper one.

// Customize how the StarDist detection should be applied
// Here some reasonable default options are specified
def stardist = StarDist2D
    .builder(modelPath)
    .channels(param1)            // Extract channel called 'DAPI'
    .normalizePercentiles(1, 99) // Percentile normalization
    .threshold(0.6)              // Probability (detection) threshold
    .pixelSize(0.15)              // Resolution for detection
    .cellExpansion(0.0)            // Expand nuclei to approximate cell boundaries
    .measureShape()              // Add shape measurements
    .measureIntensity()          // Add cell measurements (in all compartments)
    .build()
	
// Define which objects will be used as the 'parents' for detection
// Use QP.getAnnotationObjects() if you want to use all annotations, rather than selected objects
def pathObjects = QP.getAnnotationObjects()

// Run detection for the selected objects
def imageData = QP.getCurrentImageData()
if (pathObjects.isEmpty()) {
    QP.getLogger().error("No parent objects are selected!")
    return
}

//Write the right channel names in the order they are in the image
setChannelNames(
     'DAPI',
     'LEDGF',
     'MecP2',
     'MecP2_enhanced'
)

//Set pixel width and height
setPixelSizeMicrons(0.1725000, 0.1725000)

selectAnnotations();

stardist.detectObjects(imageData, pathObjects)
stardist.close() // This can help clean up & regain memory

if (param2 == "Yes") {
    runObjectClassifier(param3);
}

