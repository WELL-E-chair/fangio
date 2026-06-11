
# Fangio Version 2

Analysis toolkit to generate enriched video data with movement index curves measured on user-selected regions of the video (e.g. cow head). 
Can be used with any type of scenario (tie or free stall, indoors or outdoors) to support behavioral analysis workflows.



## Requirements

* MATLAB


## Instructions

Before running the code, set the following variables to appropriate values in `fangio_v2.m`:

| Argument          | Description                                        |
| ----------------- | -------------------------------------------------- |
| `data_folder`     | folder containing the videos to be processed       |
| `file`            | name of the video                                  |
| `results_folder`  | folder where the augmented video should be stored  |

The script will create a folder inside `results_folder` with the same name as the video.
Save and run the script.


### Step 1: Trace the regions where movement indices should be computed

<img width="1200" height="550" alt="" src="https://github.com/WELL-E-chair/fangio/blob/main/images/fangio1.png?raw=true" />


This is done using the mouse. Place the cross over the desired location and press the left-button of the mouse to place a point there. Click on the first point to close the region.

Then a dialog box appears. Click “Yes” if you need to enter another sampling region, or “No" if you are done and want to move to the next step. Clicking on “No” closes the window and starts Step 2.


### Step 2: Computation of the movement indices

Performed automatically. The user has nothing to do. The script displays its progress and an estimation of the time remaining until step completion.

```
Step 2: Extract the movement indices.
-----------------------------------------------
Starting computation of the 3 movement indices...
Processed 1000 frames of 27001. Processing time remaining about 9mins and 27secs
Processed 2000 frames of 27001. Processing time remaining about 9mins and 22secs
Processed 3000 frames of 27001. Processing time remaining about 9mins and 12secs 
…
```


### Step 3: Crop the video to remove unnecessary information

<img width="1200" height="550" alt="" src="https://github.com/WELL-E-chair/fangio/blob/main/images/fangio2.png?raw=true" />

Draw a rectangular box with the mouse to delimit which part of the image the user wants to feature in the augmented video.  This speeds up the generation of the augmented video and makes the corresponding file smaller. It also leaves less room to display the movement indices curves.
Once the crop region was entered, the window closes itself and Step 4 starts.


### Step 4: Select the frame region where movement curves will be displayed

<img width="550" height="600" alt="" src="https://github.com/WELL-E-chair/fangio/blob/main/images/fangio3.png?raw=true" />

Using the mouse, select a rectangular region where movement indices are displayed. Once done, the script closes the window and starts Step 5.


### Step 5: Inspection of the augmented video format and presentation

This is just to allow the user to see how things will look like in the augmented video before starting the somewhat lengthy process of augmented video generation. 
The script displays the first frame of the augmented video and asks for user input:

<img width="600" height="650" alt="" src="https://github.com/WELL-E-chair/fangio/blob/main/images/fangio4.png?raw=true" />

The script displays the first frame of the video exactly like it will be in the augmented video, and asks the user if they are happy with the format and presentation. 
If the user presses `No` the script will stop and the user can start over from scratch.
If the user presses `Yes`, then the window closes itself and the final step starts.


### Step 6: Generation of the augmented video

The script generates the augmented video on screen and stores it in RAM. 
As the process unfolds, the user can see the result and how long the process is expected to last:

```
Step 6: Create the augmented video.
------------------------------------------------------------------------------
 Processed 100 frames of 27001. Processing time remaining: about 21mins and 42secs
Processed 200 frames of 27001. Processing time remaining: about 20mins and 46secs
Processed 300 frames of 27001. Processing time remaining: about 20mins and 27secs
Processed 400 frames of 27001. Processing time remaining: about 20mins and 13secs
Processed 500 frames of 27001. Processing time remaining: about 20mins and 0secs
Processed 600 frames of 27001. Processing time remaining: about 19mins and 58secs
```

Once finished, the video is written in a file and the script stops after displaying the total time taken for video generation.

