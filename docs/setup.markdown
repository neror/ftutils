---
layout: default
title: FTUtils Setup

---

Setting Up FTUtils
------------------

FTUtils is most easily used by simply copying `FTUtils.h`, `FTAnimationManager.h` and `FTAnimationManager.m` into your project. Be sure to add the QuartzCore framework to your project as well (step 5 below). The preferred way to integrate FTUtils into your projects is by adding it as a static library. This will keep it separate from your code.

The following is the process to add the FTUtils static library to your Xcode project (these steps were borrowed from the [three20 project](http://github.com/joehewitt/three20/tree/master "joehewitt's three20 at master - GitHub") and modified):

 1. Clone the ftutils git repository: `git clone git://github.com/neror/ftutils.git`. Make sure you store the repository in a permanent place because Xcode will need to reference the files every time you compile your project.
 1. If you are already using git to manage your source files, you can also add the ftutils repository as a submodule to your project.
 1. Locate the "FTUtils.xcodeproj" file under "ftutils". Drag FTUtils.xcodeproj and drop it onto the root of your Xcode project's "Groups and Files" sidebar. A dialog will appear -- make sure "Copy items" is unchecked and "Reference Type" is "Relative to Project" before clicking "Add".
 1. Now you need to link the FTUtils static library to your project. Click the "FTUtils.xcodeproj" item that has just been added to the sidebar. Under the "Details" table, you will see a single item: libFTUtils.a. Check the checkbox on the far right of libFTUtils.a.
 1. Now you need to add FTUtils as a dependency of your project, so Xcode compiles it whenever you compile your project. Expand the "Targets" section of the sidebar and double-click your application's target. Under the "General" tab you will see a "Direct Dependencies" section. Click the "+" button, select "FTUtils", and click "Add Target".
 1. Now you need to add the Core Animation framework to your project. Right click on the "Frameworks" group in your project (or equivalent) and select Add > Existing Frameworks. Then locate QuartzCore.framework and add it to the project.
 1. Finally, we need to tell your project where to find the FTUtils headers. Open your "Project Settings" and go to the "Build" tab. Look for "Header Search Paths" and double-click it. Add the relative path from your project's directory to the "ftutils/Headers" directory.
 1. While you are in Project Settings, go to "Other Linker Flags" under the "Linker" section, and add "-ObjC" and "-all_load" to the list of flags.

You're ready to go! Just import the header(s) in your code for the parts of the library you'd like to use. The FTAnimation.h header includes everything in the library. So you can just include it:

{% highlight objc %}
#import <FTUtils/FTAnimation.h>
{% endhighlight %}

Enjoy! And extra super special thanks to [Joe Hewitt](http://www.joehewitt.com/ "Joe Hewitt") for writing these steps out for his [three20 project](http://github.com/joehewitt/three20/tree/master "joehewitt's three20 at master - GitHub")! I don't think I have the patience to pull it off.
