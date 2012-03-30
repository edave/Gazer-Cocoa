GazerCocoa :: Bolt-on gaze tracking for OS X
=================================================

GazerCocoa is an OS X service for easily incorporating gaze tracking into any mac application with only a few lines of code. GazerCocoa wants to employ the unused webcam sitting on the top of every Mac's display.

Gaze tracking is a quick, low-precision and low-cost method to determine where a user is focused. It's the cheaper cousin of eye tracking, which strives for precision with expensive, high quality equipment.

Common Questions:

_But don't I want eye tracking?_

Probably not.

Are you running a controlled experiment to determine which apple someone is looking at in a photograph of a tree? Then yes, you would want eye tracking. Otherwise, gaze tracking probably meets your requirements.

_So now I can control my computer with my eyes instead of my mouse?_

Probably not.

Although eye/gaze tracking has been used as a replacement for the mouse, it requires extensive user training and is usually not worth the hassle. Unless you have the ability to move objects with your mind, or tell someone that these aren't the droids they're looking for, your gaze mostly represents where your focus is.

The point is, there's a lot of cool things you can do with passive gaze/face tracking. That's why we want this to be open source, to see how people push the boundaries.

Contributors
------------------------------
* [edave](https://github.com/edave), [LabCogs](http://www.labcogs.com)
* [rkabir](https://github.com/rkabir)
* Based on [OpenGazer](https://github.com/OpenGazer/OpenGazer)

How to Use
=================================================

GazerCocoa runs as a separate process in the background. You are responsible for starting and terminating GazerCocoa as necessary (see the wiki/examples directory). Communication with GazerCocoa happens via the Cocoa's NSDistributedNotificationCenter (see [Notification Center](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Notifications/Articles/NotificationCenters.html) ) using a combination of pre-defined keys and NSDictionaries

For example, to tell GazerCocoa you want to calibrate, you would use:

```
[[NSDistributedNotificationCenter defaultCenter] 
postNotificationName: kGazeTrackerCalibrationRequestStart 
              object:kGazeSenderID
            userInfo:nil
  deliverImmediately:YES];
```

which will kick off the calibration interface for the user.

To receive gaze location updates is just as simple:

```
[[NSDistributedNotificationCenter defaultCenter] addObserver:self
               selector:@selector(gazePointBroadcasted:)
                   name:kGazePointNotification
                 object:kGazeSenderID];
```

when a new gaze point is broadcasted, your notification method will be called with an NSDictionary containing the coordinates of the gaze (where top-left is 0,0, in contrast to Cocoa's coordinate system of bottom-left being 0,0)

```
-(void)gazePointBroadcasted:(NSNotification*)note{
    NSDictionary* userInfo = [note userInfo];
    NSPoint point;
    point.x = [(NSNumber*)[userInfo objectForKey:kGazePointXKey] floatValue];
    point.y = [(NSNumber*)[userInfo objectForKey:kGazePointYKey] floatValue];
}
```

That's it! See the wiki for a full [list of the notifications](https://github.com/edave/OpenGazer-Cocoa/wiki/Notifications) you can subscribe to, and what you can tell GazerCocoa to do. See the [examples](https://github.com/edave/OpenGazer-Cocoa/tree/master/examples) directory for an implementation that interacts with OpenGazer. For an example application that uses OpenGazer Cocoa, see [Blinders](http://labcogs.com/blinders)

How to Build/Develop
=================================================
GazerCocoa depends upon a few different libraries, and as such, can't be built out of the box. Installing the supporting libraries is a straightforward process:

Dependent Libraries:

* Boost
* OpenCV 2
* VXL
* OpenGazer (included with the GazerCocoa project, no need to download)

How you install these libraries is up to you- if you already them installed, skip to the last step. Here's a suggested workflow that makes things as easy as possible with a combination of brew and macports:

`brew install boost
brew install opencv
`

Reconfigure ports to use LLVM GCC instead of CLANG for installing vxl

`sudo port install apple-gcc42
sudo port install vxl configure.compiler=apple-gcc-4.2 configure.cxx=g++-apple-4.2
`

In the GazerCocoa XCode project, you will need to add paths to the Header Search Path to where these libraries are installed. 

For example, using these install instructions, they might look like this:
`/opt/local/include/vxl/vcl /opt/local/include/boost /opt/local/include/vxl/core/vnl /opt/local/include/vxl/core /opt/local/include/vxl /opt/local/include
`

GazerCocoa has four different schemas you can build:

* GazerCocoa Debug - This is the normal way GazerCocoa runs, as a background process but with the standard Debug options set for a XCode process. It starts up and then waits for notifications to display the calibration UI. Useful for debugging and testing with other applications.
* GazerCocoa GUI - GazerCocoa starts normally, but then immediately launches the calibration UI. Useful for development at a high level.
* GazerCocoa OpenCV - This is a derivative of the GUI schema, but also displays additional windows/logs useful for debugging OpenCV. Useful for low-level development.
* GazerCocoa Release - The normal way GazerCocoa runs, as a background process, but optimized. Use this for releasing with your applications.

License
=================================================
**WARNING**
GazerCocoa's license will be changing in the near future from GPLv2 to a more permissive license like the MIT license. While we don't have anything against GPLv2, it is not the best fit for this type of project.
**END WARNING**

Currently GazerCocoa is licensed under the GPLv2, with other elements available as a dual license. OpenGazer, which GazerCocoa relies upon, is entirely under the GPLv2 License.

Thanks to
=================================================
The folks at the University of Surrey for the OpenGazer project. See their [GitHub project](https://github.com/OpenGazer/OpenGazer)