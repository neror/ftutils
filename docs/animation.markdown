---
layout: default
title: FTAnimation
permalink: animation

---

Using FTAnimation
-----------------

FTAnimation was designed to make complex Core Animation based animations simple to create and use. The primary interface into the pre-built animations is a [category on `UIView`](http://localhost:4000/docs/uiview-ftanimation/ "UIView Extensions"). Animating a view is as simple as:

    [myView slideInFrom:kFTAnimationBottom duration:.33f delegate:self];
    
You can also access the `CAAnimation` instances that power the category methods via the `FTAnimationManager` singleton like so:

    CAAnimation *anim = [[FTAnimationManager sharedManager] slideInAnimationFor:myView 
                                                                      direction:kFTAnimationBottom
                                                                       duration:.33f
                                                                       delegate:self];
                                                            
modify it to your satisfaction and/or add it to a `CAAnimationGroup` and add it to the view's layer when you're ready to use it:

    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInOut];
    [myView.layer addAnimation:anim forKey:@"MySpecialAnimation"];
    
See the code for details.