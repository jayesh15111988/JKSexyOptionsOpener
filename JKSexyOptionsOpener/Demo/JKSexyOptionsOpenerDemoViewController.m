//
//  JKSexyOptionsOpenerDemoViewController.m
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/28/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKSexyOptionsOpenerDemoViewController.h"
#import "JKAnimatedOptionsOpenerView.h"

@interface JKSexyOptionsOpenerDemoViewController ()
@property (strong) JKAnimatedOptionsOpenerView* JKAnimatedViewInstance;
@property (strong) UIView* animatedView;
@end

@implementation JKSexyOptionsOpenerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JKOption* firstOption = [[JKOption alloc] initWithTitle:@"first" andImageName:@"red.png"];
    JKOption* secondOption = [[JKOption alloc] initWithTitle:@"second" andImageName:@"orange.png"];
    JKOption* thirdOption = [[JKOption alloc] initWithTitle:@"third" andImageName:@"blue.png"];
    
    self.JKAnimatedViewInstance = [[JKAnimatedOptionsOpenerView alloc] initWithParentController:self andOptions:@[firstOption, secondOption, thirdOption]];
    
    self.JKAnimatedViewInstance.OptionSelectedBlock = ^(NSUInteger optionSelected) {
        NSLog(@"Selected options is %lu", optionSelected);
    };
    
    self.JKAnimatedViewInstance.OptionNotSelectedBlock = ^() {
        NSLog(@"Operation cancalled");
    };

    
    //Setup parameters to use with this overlay
    [self.JKAnimatedViewInstance setOverlayBackgroundEffect:Transparent];
    self.JKAnimatedViewInstance.mainOptionsButtonTitle = @"Sexy Options";
    self.JKAnimatedViewInstance.mainOptionsButtonBackgroundImageName = @"gray.png";
    self.JKAnimatedViewInstance.optionButtonsDimension = 30;
    //These are default color parameters - User can change them before calling createAndSetupOverlayView method on foreground overlay view
    self.JKAnimatedViewInstance.optionsLabelTextColor = [UIColor redColor];
    self.JKAnimatedViewInstance.overlayBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    //Create an actual view
    [self.JKAnimatedViewInstance createAndSetupOverlayView];
}

- (IBAction)openOptionsButtonPressed:(id)sender {
    [self.JKAnimatedViewInstance openOptionsView];
}


@end
