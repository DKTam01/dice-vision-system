# dice-vision-system
**Real-Time Computer Vision & Noise Filtration Project Overview**

This project is an automated computer vision system developed in MATLAB that processes live webcam footage to calculate real-time metrics. The core objective of the script is to take raw, live-streamed video and apply digital signal processing techniques to filter out environmental noise and cleanly extract specific visual data. Specifically, this program processes an image of a dice to extract the number of dots.

**Key Features**

Live Feed Integration: Captures and processes video data directly from a webcam stream.

Automated Noise Filtration: Utilizes algorithmic filtering to dynamically clean up visual artifacts and background interference.

Real-Time Analytics: Continuously calculates and outputs specific metrics based on the isolated subjects in the video feed.

**Technical Stack**

Language: MATLAB

Concepts: Computer Vision, Digital Signal Processing, Real-Time Data Extraction, Automated Scripting

**Limitations**

The image processing crops to dice region, but the metrics to determine dice region are pre-set with numbers meant for a specific dice landing area along with specific camera height and FOV (Please refer to line 26). The program also expects the background of the dice to be blue (Please refer to lines 40-46 to change background color). 
