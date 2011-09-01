---
layout: default
title: Building and Installing the API Docs and Xcode Docset

---

Adding the Docs to Xcode
------------------------

The simplest way to get the FTUtils documentation into Xcode is to use the docset feed. Xcode will automatically fetch the documentation and keep it up to date. The docset feed url is:

    http://ftutils.com/docs/api/docset/com.freetimestudios.FTUtils.atom

In Xcode 4, the documentation feeds are managed in the *Documentation* tap in the preferences window. Simply click the + button to add the docset URL. This is how it looks in Xcode 4:

![Xcode 4 Documentation Preferences](/images/add_docset_feed.png)

Building the API Docs Yourself
------------------------------

The included [`Makefile`](http://github.com/neror/ftutils/blob/master/Makefile "Makefile at master from neror's ftutils - GitHub") makes building the API docs simple. To build the API docs you'll need to pull down and build [appledoc](http://tomaz.github.com/appledoc/ "appledoc").

Once you have downloaded and installed *appledoc*, ensure that the `appledoc` binary is on your path and run

{% highlight console %}
$ make docs
{% endhighlight %}
    
This will generate the docs and place them in `<PATH_TO_FTUTILS>/apidocs/html`

Building and Installing the Xcode Docset
----------------------------------------

Thanks to the magic of *appledoc*, creating an Xcode docset from the API docs is very simple. Just run

{% highlight console %}
$ make docsetinstall
{% endhighlight %}

This will build the docs and the Xcode docset and copy the docset bundle to `~/Library/Developer/Shared/Documentation/DocSets`.
    
This makes the documentation available and searchable in the Xcode documentation window. The regular HTML documentation will also be available in the same directory as before.
