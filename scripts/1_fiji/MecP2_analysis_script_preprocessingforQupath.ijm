// @ File(label="File directory", style="directory") dir

// @String (visibility=MESSAGE, value="Parameters for blob segmentation", required=false) msg1
// @Integer (label="Channel containing the blob marker", min=1, max=4, value=4) blob_channel

// @ String (label="File suffix", choices={".czi", ".tif"}, style="listBox") suffix

/* 24/05/2024
Nicolas Peredo
VIB BioImaging Core Leuven - Center for Brain and Disease Research
Nikon Center of Excellence
Campus Gasthuisberg - ON5 - room 04.367
Herestraat 49 - box 62
3000 Leuven
Belgium
phone +32 (0)16/37.70.03

When you publish data analyzed with this script please add the references of the used plug-ins:

This script takes a multiple channel image containing a channel with speckles. The script generates a new channel with enhances speckles for analysis in Qupath.
*/

//Get directories and lists of files
setOption("ExpandableArrays", true);

//Blood vessel directory
fileList = getFilesList(dir, suffix);
Array.sort(fileList);

//Create the different folders with results
File.makeDirectory(dir + "/Processed");

/*Script to use in case ROI order in not correct
//Define arrays
setOption("ExpandableArrays", true);
name_index = newArray();
name_index_count = 0;

roiManager("List");
roi_name_list = Table.getColumn("Name");

for (files = 0; files < fileList.length; files++) {
	//File and ROI names
	file = fileList[files];
	name = getBasename(file, suffix);

	for (roi = 0; roi < fileList.length; roi++) {
		roi_name = roi_name_list[roi];
		if (roi_name == name) {
			name_index[name_index_count] = roi;
			name_index_count = name_index_count + 1;
		}
	}	
}
*/

for (files = 0; files < fileList.length; files++) {
//for (files = 80; files < 81; files++) {
	
	//File and ROI names
	file = fileList[files];
	name = getBasename(file, suffix);
	
	//Open image
	run("Bio-Formats Importer", "open=[" + dir + File.separator + file + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	rename("Raw_Image");
	
	//Get parameters from image
	getDimensions(width, height, channels, slices, frames);
	getPixelSize(unit, pixelWidth, pixelHeight);
	
	//setBatchMode(true);
	
	//Detecting the MecP2 signal
	//Get MecP2 channel
	selectWindow("Raw_Image");
	run("Duplicate...", "title=Blob_channel duplicate channels=" + blob_channel + "-" + blob_channel);
	
	//Enhance image
	enhance_speckels("Blob_channel");
	rename("enhanced_image");
	
	//Reassign pixel size since the generated filtered image is not calibrated anymore
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=" + pixelWidth + " pixel_height=" + pixelWidth + " voxel_depth=1.0000000");
	
	//Generate the processed image with the added channel
	mergestring = "";
	for (channel = 0; channel < channels; channel++) {
		selectWindow("Raw_Image");
		run("Duplicate...", "duplicate channels=" + (channel+1) + "-" + (channel+1));
		rename("channel_" + channel);
		
		channel_string = "c" + (channel+1) + "=[channel_" + channel + "] ";
		mergestring = mergestring + channel_string;
	}
	mergestring = mergestring + "c" + (channel+1) + "=[enhanced_image] create keep";
	run("Merge Channels...", mergestring);
	rename(name);
	/*
	//Cropping ROI
	roiManager("Select", files);
	
	//Scale ROI to the full resolution image
	run("Scale... ", "x=82 y=82");
	roiManager("update");
	*/
	
	//Crop the ROI
	selectWindow(name);
	roiManager("Select", files);
	run("Clear Outside", "stack");

		
	//waitForUser;

	//Process to become 32-bit for intensity measurements
	run("Kheops - Convert Image to Pyramidal OME TIFF", "output_dir=" + dir + "/Processed/" + " compression=Uncompressed subset_channels= subset_slices= subset_frames= compress_temp_files=false");

	//waitForUser;

	//Close non important windows
	close("*");
	run("Collect Garbage");
	
}
	
//Extract a string from another string at the given input smaller string (eg ".")
function getBasename(filename, SubString){
  dotIndex = indexOf(filename, SubString);
  basename = substring(filename, 0, dotIndex);
  return basename;
}

//Return a file list contain in the directory dir filtered by extension.
function getFilesList(dir, fileExtension) {  
  tmplist=getFileList(dir);
  list = newArray(0);
  imageNr=0;
  for (i=0; i<tmplist.length; i++)
  {
    if (endsWith(tmplist[i], fileExtension)==true)
    {
      list[imageNr]=tmplist[i];
      imageNr=imageNr+1;
      //print(tmplist[i]);
    }
  }
  Array.sort(list);
  return list;
}

//Function to segment blobs. Only needs image to be used as input
function enhance_speckels(blob_image) { 
	selectWindow(blob_image);
	rename("blob_image");
	
	run("Subtract Background...", "rolling=10");
	run("CLIJ2 Macro Extensions", "cl_device=[NVIDIA GeForce RTX 3070]");
	
	// difference of gaussian
	image_1 = "blob_image";
	Ext.CLIJ2_pushCurrentZStack(image_1);
	
	// Copy
	Ext.CLIJ2_copy(image_1, image_2);
	Ext.CLIJ2_release(image_1);
	
	Ext.CLIJ2_pull(image_2);
	
	// Difference Of Gaussian2D
	sigma1x = 2;
	sigma1y = 2;
	sigma2x = 10;
	sigma2y = 10;
	Ext.CLIJ2_differenceOfGaussian2D(image_2, image_3, sigma1x, sigma1y, sigma2x, sigma2y);
}