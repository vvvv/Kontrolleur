Kontrolleur is a proof of concept open source general purpose remote controlling app for Android written in [Processing](http://processing.org). It displays (using simple autolayout) interface elements (slider, button,...) that are being pushed to it via [OSC](http://opensoundcontrol.org/spec-1_0) by the target application and sends back values to given OSC addresses on the target application. 

Its main idea is ease of use by not requiring you to create an interface layout manually and assign its values to parameters in your target application. Instead the target application can expose specific interface elements on the fly without any further manual assignment needed by the user. 

Additionally Kontrolleur can display the current value of a parameter as set by the target application and it can send multiple touches and sensors (accelerometer, orientation, magnetic field) directly to the target application. 

While conceived for plug and play compatibility with [vvvv](http://vvvv.org) it can be easily adopted by any software capable of sending and receiving OSC.

A demo-video is here:
http://vimeo.com/22041214

###Usage

Starting Kontrolleur on your phone for the first time prompts you with the menu. There you can set the IP Address and Port of your target application. The IP defaults to a broadcast IP on your current subnet which should be fine for a start. P ressing the _Save_ button saves those settings and starts the network connection. Next time you start Kontrolleur those settings are loaded and used. To change settings use the _Menu_ button on your phone at any time to bring up the menu again. 

From the target application you can now send OSC messages in the following format to create interface elements:

*  /k/add sssfffff
*  /k/update sssfffff
*  /k/remove s

where the typetags have to be used as follows:

*  s: OSC address on target application
*  s: parameter name
*  s: parameter type (accepts: Slider, Endless, Toggle, Bang)
*  f: default value for parameter (can be reset to via two button click on parameter)
*  f: minimum
*  f: maximum
*  f: stepsize
*  f: current value of parameter

Pressing the _Save_ button in the menu sends an OSC message to the target application in the form of:

*  /k/init siii
where the typetags deliver the following data:
*  s: device IP
*  i: device Port
*  i: width of device pixels
*  i: height of device pixels

The target application is supposed to use IP and Port to communicate back to the device and use width and height to map the touch data to a range preferred by the application.

When activated in the menu Kontrolleur will send touches and sensors on the following OSC addresses:

*  /touch ifff.... (touch ID, x, y, pressure) 
*  /orientation fff
*  /acceleration fff
*  /magnetism fff

###Credits
*  Eric Pavey for [hints on multitouch](http://www.akeric.com/blog/?p=1435) and [package signing](http://www.akeric.com/blog/?p=1352)
*  Rikard Lundstedt for the [apWidgets library](http://code.google.com/p/apwidgets)
*  Daniel Sauter et al for the [ketai sensor library](http://code.google.com/p/ketai)
---
Looking forward to [Control](http://charlie-roberts.com/Control/) for Android, which hopefully makes Kontrolleur obsolete...