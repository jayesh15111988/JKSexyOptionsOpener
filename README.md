##JKSexyOptionsOpener

A Sexy option opener for iOS with Spring animation and highly portable across devices and orientations
I came out about creating this library while looking at similar animations made by another app. (My apology, but I forgot the name of the app). However, this is very simple to use library to present available options in interactive way. I have made use of UIView animation APIs as well as new spring view animation introduced on iOS7.

##Here is the GIF showing the little demo for this library : 

![alt text][sexyOptionsLibraryDemoImage]

**How to add JKSexyOptionsOpener in the project.**

You can easily add this library in the project using Cocoapods. Just update your podfile with following line. (_Recent release version 0.2.0_)

```
pod 'JKSexyOptionsOpener', :git => 'https://github.com/jayesh15111988/JKSexyOptionsOpener', :branch => 'master'
```

- Alternatively, if you want to use specific commit or tag you can specify so in the above line by replacing branch with suitable option.

- Once you have added this line, just install pod install / pod update from command line. It will install all required dependencies in the Pods folder accordingly

**How to use this library?**

Once you have successfully added project files, you are ready to use it as follows : 

Add this line in the header (.h) or implementation (.m) file,   
``` #import <JKAnimatedOptionsOpenerView.h> ```

First specify the option titles and background images as the array of dictionaries,
```
NSArray* animatedOptionscollection = @[@{JKOPTION_BUTTON_TITLE : @"First", JKOPTION_BUTTON_IMAGE_NAME : @"red.png"}, @{JKOPTION_BUTTON_TITLE : @"Second", JKOPTION_BUTTON_IMAGE_NAME : @"orange.png"}];
```
where,  
```JKOPTION_BUTTON_TITLE``` - Is the option name key   
```JKOPTION_BUTTON_IMAGE_NAME``` - Is key for name of the background image applied to option button

Now instantiate Animation options view to use with following line, 
```
JKAnimatedOptionsOpenerView* JKAnimatedViewInstance = [[JKAnimatedOptionsOpenerView alloc] initWithParentController:self andOptions:animatedOptionscollection];
```

Where ```self``` is the viewController in which overlay view is to be added.

Once this is done, specify following parameters before actually creating overlay view for use. Options and their descriptions are as follows.

_backgroundEffect_ - There are two background effects. Blurred and Black transparent. This could be set with method,

```- (void)setOverlayBackgroundEffect:(OverlayViewBackgroundEffect)backgroundEffect; ```  
Please remember that this method updates option titleColor to maintain desired contrast. You might want to update text color after calling this method. **(Default : Transparent black)**

_expansionRadius_ - This is the expansion radius which decides the distance by which options expand from center button. If this value exceeds certain limit, library will update its value to keep it within the bounds of frame. This property can be set with following method.
```- (void)setExpansionRadiusWithValue:(CGFloat)expansionRadius; ```  
**(Default : Half the width of current view)**

_optionsLabelTextColor_ - Color of options text **(Default : Black)**

_defaultTextFont_ - Default font for options text **(Default: HelveticaNeue-Light with size of 12 px)**

_overlayBackgroundColor_ - Overlay background color **(Default : Trnasparent Black)**

_mainOptionsButtonTitle_ - Title for center button **(Default : Main)**

_mainOptionsButtonBackgroundImageName_ - Background image name for center button

_optionButtonsDimension_ - Dimension for size of option buttons **(Default : 30px)**

__Once options are setup, specify blocks to facilitate callbacks one user either selects any option or dismisses overlay view without selecting one.__

```
self.JKAnimatedViewInstance.OptionSelectedBlock = ^(NSUInteger optionSelected) {
    //We will land here if user selects any given option            
}
```

```
self.JKAnimatedViewInstance.OptionNotSelectedBlock = ^() {
   //We will land here if user dismisses overlay without choosing a single option
}
```

Now create an overlay view by calling following method. Overlay view will be automatically created within the bounds of view of current viewController. But will be invisible until we execute another method to make it appear on the viewport
```
[JKAnimatedViewInstance createAndSetupOverlayView];
```
Now if you want specific button to trigger overlay display operation, attach it to IBOutlet and simply call following method on animated view instance ```JKAnimatedViewInstance```
```
//Open or close overlay view
[JKAnimatedViewInstance openOptionsView];
```

And that's it. It's done already. It is very basic and I am looking forward to add more new features. If you have any criticism/feedback/suggestion on improving this library please let me know.

Enjoy!

[sexyOptionsLibraryDemoImage]: https://github.com/jayesh15111988/JKSexyOptionsOpener/blob/master/Screenshots/JKAnimated%20Options%20Demo.gif "JKOptions Opener Demo"


