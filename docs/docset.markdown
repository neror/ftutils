---
layout: default
title: Building and Installing the API Docs and Xcode Docset
permalink: docset

---

Building the API Docs Yourself
------------------------------

The included [`Makefile`](http://github.com/neror/ftutils/blob/master/Makefile "Makefile at master from neror's ftutils - GitHub") makes building the API docs simple. To build the API docs you'll need [Doxygen](http://www.stack.nl/~dimitri/doxygen/ "Doxygen"). The [prebuilt binary](http://www.stack.nl/~dimitri/doxygen/download.html#latestsrc "Doxygen") for OS X works well, and it's the recommended installation method.

Once you have downloaded and installed Doxygen, ensure that the `doxygen` binary is on your path and run

    make docs
    
This will generate the docs and place them in 

    <PATH_TO_FTUTILS>/apidocs/html

Building and Installing the Xcode Docset
----------------------------------------

Thanks to the magic of Doxygen, creating an Xcode docset from the API docs is very simple. Just run

    make docsetinstall

This will build the docs and the Xcode docset and create a symlink to the docset in 

    ~/Library/Developer/Shared/Documentation/DocSets
    
This makes the documentation available and searchable in the Xcode documentation window. The regular HTML documentation will also be available in the same directory as before.
