<img align="left" src="https://user-images.githubusercontent.com/37427166/50706897-c9156380-1024-11e9-9619-85d66212410e.png" width="150" height="150"></img>

# dwa140shortcut

A simple menu bar application to expedite usage of the DWA-140 preference pane. This application is especially useful for users with a Hackintosh computer build.

## Why dwa140shortcut?

I created this application for personal use on my macOS machine that relies on the DWA-140 preference pane. It become a task opening System Preferences, opening the pane, waiting for it to load, and hoping that my connection would be successful.

With this application, you are presented with a menubar icon that represents the current state of your network, as normal macOS also does. If you do not have a desirable network card, macOS doesn't give you the option to use the default WiFi menubar.

If you're using a USB WiFi dongle on macOS, you're more than likely downloading a driver patch for your system. This patch usually routes traffic from the dongle to your ethernet controller, connecting you to the internet. 

## Features

* Easy "shortcut" button to the DWA-140 preference pane.
* Easy "shortcut" button to the Network Preferences preference pane.
* Ability to refresh the current status of your network connection.


## Installation 

## macOS 10.12+ Release

* Download the latest release of the software from [here](https://github.com/FivePixels/dwa140shortcut/releases).

### **Make sure you have the following installed prior to installing this application:**

* _RT2870USBWirelessDriver.kext_ in `/System/Library/Extensions/`
* _DWA-140WirelessUtility.prefPane_ in either `/Library/PreferencePanes/` or `~/Library/PreferencePanes/`


### Setup 

1. Open the `DWA140Menu.dmg` file.
2. Drag and drop the `DWA140Menu.app` contained within dmg into the Applications directory.
3. ???
4. :tada:

## Other macOS versions

Currently, I do not have full support for any version below macOS 10.12. I plan in the future to add full support but some of the frameworks I'm depending on only work above 10.12.

I have created a specific version temporarily for 10.10 [here](https://github.com/FivePixels/dwa140shortcut/issues/1#issuecomment-449897887).

## Upcoming Features
- [ ] Toggle to enable application as soon as the user logs in.
- [ ] Update the menubar correctly, without needing to reload the application.
- [ ] Update the menubar accurately according to range.
- [ ] Perform a check to make sure the connection isn't captive, and if it is, present the user with an error letting them know.
