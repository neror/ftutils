---
layout: default
title: FTAnimation

---

Using FTAnimation
-----------------

FTAnimation was designed to make complex Core Animation based animations simple to create and use. The primary interface into the pre-built animations is a [category on `UIView`](/docs/uiview-ftanimation/). Animating a view is as simple as:

{% highlight objc %}
[myView slideInFrom:kFTAnimationBottom duration:.33 delegate:self];
{% endhighlight %}

You can also access the `CAAnimation` instances that power the category methods via the `FTAnimationManager` singleton like so:

{% highlight objc %}
CAAnimation *anim = [[FTAnimationManager sharedManager] slideInAnimationFor:myView 
                                                                  direction:kFTAnimationBottom
                                                                   duration:.33
                                                                   delegate:self];
{% endhighlight %}
                                                            
modify it to your satisfaction and/or add it to a `CAAnimationGroup` and add it to the view's layer when you're ready to use it:

{% highlight objc %}
anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInOut];
[myView.layer addAnimation:anim forKey:@"MySpecialAnimation"];
{% endhighlight %}
    
See the code for details.
