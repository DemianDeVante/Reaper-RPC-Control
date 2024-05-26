# RPC Control and Scripts for Reaper DAW
This is a collection of scripts and custom actions made in order to make MIDI controllers more useful with Reaper.  

[![Video](https://img.youtube.com/vi/4QIFIsZSVJ8&t=328s/0.jpg)](https://www.youtube.com/watch?v=4QIFIsZSVJ8&t=328s)

## Features
* **RPC Control:**  
  A minimalistic ReaLearn Template in order to achieve a nearly mouseless workflow, influenced by MPC workstations.  
* **Looper D:**  
  A script collection aimed to make live looping easier, taking advantage of the native takes system.
* **Demian D Scripts:**  
  Various scripts made mainly for use with MIDI controllers.

## Use & Overview
The RPC Control template consists of 4 Modes (Toolbar, Mixer, Looper, Disabled) that can be switched with a modifier button (mod + pad 1-4) or program change messages (pc 1-4).  
Each Mode has different modifiers to perform different functions, these are short press, long press and long long press.  
A long long press with any pad (around 1700ms) will reset all modifiers in the Mode.  
### Toolbar Mode
Has 8 Toolbabars you can switch with a long press, each with 16 actions you can trigger with Pads (short press) and 8 functions you can perform with Knobs.  
A descriptive label on the functions assigned to the knobs is displayed at the rightmost side of the toolbar.  

* **Main Toolbar**
<img src="https://user-images.githubusercontent.com/113860974/191438004-c3756884-6b86-4f63-85f7-144f3fd76f16.gif" width="700" />

* **Item Edit Toolbar**
<img src="https://user-images.githubusercontent.com/113860974/191437973-839b8f13-80c0-4399-8474-7dcb945c14e1.gif" width="700" />

* **Item Tools Toolbar**
<img src="https://user-images.githubusercontent.com/113860974/191437978-4489b680-4a49-43a5-b227-8dd296222f16.gif" width="700" />

* **Track Tools Toolbar**
<img src="https://user-images.githubusercontent.com/113860974/191438047-8be3c846-d04a-41e3-8c9a-68d9af978794.gif" width="700" />

* **MIDI Editor Toolbar**
<img src="https://user-images.githubusercontent.com/113860974/191438015-2eba87dc-90ee-4769-a9df-317d821288a2.gif" width="700" />

* **Media Explorer Toolbar**
<img src="https://user-images.githubusercontent.com/113860974/191438008-2a635cc4-8032-4933-9cf1-2f8b15a8965f.gif" width="700" />

* **FX Tools Toolbar**
<img src="https://user-images.githubusercontent.com/113860974/191437957-93b5b5a5-42eb-4d7b-8aec-b4ed029ec77a.gif" width="700" />

* **Project Settings Toolbar** 
<img src="https://user-images.githubusercontent.com/113860974/191438036-279bae56-5888-44a8-ba26-0eef3e656dd2.gif" width="700" />


### Mixer Mode
Only shortpress needed.  
The first 8 Pads will change the behavior of the knobs to control the volume in sets of 8 tracks, up to 64 tracks.  
The next 8 Pads will change the behavior of the knobs to control the pan in sets of 8 tracks, up to 64 tracks.  

<img src="https://user-images.githubusercontent.com/113860974/191438027-d8015a17-bdb6-4412-be19-fb3f717ae805.gif" width="700" />

### Looper Mode
A short press will change the take from 1 to 16 depending on the Pad pressed.  
A long press with any pad will mute the take.  

<img src="https://user-images.githubusercontent.com/113860974/191437985-e3d45f43-9eaa-4c4d-838a-84160983c9f0.gif" width="700" />

### Disabled Mode
In this Mode only the modifier button and program change messages will work, all the other Pads and Knobs are free to use with any Learn system (i.e. Reaper Action List or Parameter Learn)
  
## Requirements
### Demian D Scripts & Looper D
* [SWS Extension](https://www.sws-extension.org/)
* [Reapack](https://reapack.com/)
* [ReaScript API](https://forum.cockos.com/showthread.php?t=212174) (available through Reapack).

### RPC Control
* A MIDI controller with at least 17 Pads/Buttons/Triggers and 8 Knobs (all relative/endless) (recommended).
* [ReaLearn](https://www.helgoboss.org/projects/realearn/)
* Demian D Scripts & Looper D
* [Quick Adder](https://forum.cockos.com/showthread.php?t=232928)
* [X-Raym_Move selected tracks up/down on visible track list](https://forum.cockos.com/showthread.php?t=178071) (available through Reapack)
* [MIDI Mute Group](https://forum.cockos.com/showthread.php?t=141444) (recommended for an MPC style Drum Trigger)

## Installation
To open the Reaper Resource Path go to (Options >> Show Reaper resource path in explorer/finder...).  

<a href="url"><img src="https://user-images.githubusercontent.com/113860974/191146302-e6bc7f96-15f2-4317-b8bf-177025e5368c.jpg" width="550" ></a>

### Demian D Scripts & Looper D
* Copy the Scripts folder into Reaper Resource Path.
* Import "Demian D Script Pack.ReaperKeyMap" through: (Action List >> Key map... >> Import shortcut keymap).  

<a href="url"><img src="https://user-images.githubusercontent.com/113860974/191146345-0d6454f5-3a74-41f0-927d-9cdbc70c0bfb.jpg" width="550" ></a>

* In (Preferences >> Audio >> Loop Recording)  make sure "At each loop (creates new files, good for recording multiple audio layers on the fly etc)" is disabled.

<a href="url"><img src="https://user-images.githubusercontent.com/113860974/191147958-3a531ecc-dfa0-415e-a4f6-1834cdb37cb2.jpg" width="550" ></a>

### RPC Control
* Copy the Data folder into Reaper Resource Path.
* Go to (Extensions >> Startup actions >> Set global startup action...) and paste the ID of the script "Dem Startup Action.lua" (This script just makes sure Reaper Starts in Fullscreen and Loads Screenset 1. The ID is: _RS6c80eaa8a9a5bdeb85699d81fd67fba0f32f6948).  
* Copy the [sset0] configuration inside "reaper-screensets.ini", alternatively if you don't mind losing your screensets copy the whole file to Reaper Resource Path.
* Import "RPC Control Toolbars.ReaperMenuSet" through: (Options >> Customize menus/toolbars... >> Import/Export >> Import).

<a href="url"><img src="https://user-images.githubusercontent.com/113860974/191152689-1eebc6ba-a137-46e6-b8e5-56185eadf565.jpg" width="550" ></a>

* Open the Monitoring FX (View >> Monitoring FX) and insert a ReaLearn Instance.
* Choose "RPC Control" as controller preset both in main and controller compartment.

<a href="url"><img src="https://user-images.githubusercontent.com/113860974/191152761-4925c86a-cacb-49d6-941d-784ca8f2858b.jpg" width="550" ></a>

* In (Controller compartment >> Mapping group >> Knobs/Pads Control Change) assign your MIDI controller knobs and buttons by clicking on "Learn Source".

<a href="url"><img src="https://user-images.githubusercontent.com/113860974/191152778-e661e1f2-5b9b-407e-8acb-f5b0068a5d68.jpg" width="550" ></a>

* In (Controller compartment >> Mapping group >> Modifier) assign the button you want to use as a modifier for changing Modes, alternatively you can assign Program Change messages to do this function.  

* Right click on toolbar and choose (Position toolbar > At top of main window)

* Because of Reaper Focuses the Arrange Toolbar on Startup you should manually click the Toolbar you want to focus.

* Whenever Reascript task control window shows up choose "Terminate instances".  

<a href="url"><img src="https://user-images.githubusercontent.com/113860974/191396140-9972c144-1fed-43fa-8162-0ebfba5ae095.png" width="550" ></a>

* Dock the MIDI Editor.

The following settings are recommended:
* In the MIDI Editor right click and set (View >> Piano Roll Timebase > Project Synced).
* In the Media Explorer right click and set (Show >> Vertical layout > Enabled).
* In Preferences:
* (Editing behavior >> Link loop points to time selection > Enabled).
* (Editing behavior >> Vertical zoom center > Last selected track).
* (Editing behavior >> Horizontal zoom center > Edit or play cursor (default)).
* (Editing behavior >> MIDI Editor >> One MIDI Editor per > project).
* (Audio >> Playback >> Scrub/jog when moving edit cursor via action or control surface > Disabled).
