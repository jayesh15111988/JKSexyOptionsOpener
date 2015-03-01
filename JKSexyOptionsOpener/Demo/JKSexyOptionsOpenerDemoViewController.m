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
@property (weak, nonatomic) IBOutlet UILabel *selectedOptionLabel;

@end

@implementation JKSexyOptionsOpenerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.JKAnimatedViewInstance = [[JKAnimatedOptionsOpenerView alloc] initWithParentController:self andOptions:@[@{JKOPTION_BUTTON_TITLE : @"First", JKOPTION_BUTTON_IMAGE_NAME : @"red.png"}, @{JKOPTION_BUTTON_TITLE : @"Second", JKOPTION_BUTTON_IMAGE_NAME : @"orange.png"}, @{JKOPTION_BUTTON_TITLE : @"Third", JKOPTION_BUTTON_IMAGE_NAME : @"blue.png"}, @{JKOPTION_BUTTON_TITLE : @"Fourth", JKOPTION_BUTTON_IMAGE_NAME : @"green.png"}, @{JKOPTION_BUTTON_TITLE : @"Fifth", JKOPTION_BUTTON_IMAGE_NAME : @"gray.png"}]];
    
    __weak typeof(self) weakSelf = self;
    self.JKAnimatedViewInstance.OptionSelectedBlock = ^(NSUInteger optionSelected) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"Selected options is %lu", optionSelected);
        strongSelf.selectedOptionLabel.text = [NSString stringWithFormat:@"You have selected option number %lu", (long)optionSelected + 1];
    };
    
    self.JKAnimatedViewInstance.OptionNotSelectedBlock = ^() {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.selectedOptionLabel.text = @"You Selected close overlay option";
        NSLog(@"Operation cancalled");
        
    };

    
    //Setup parameters to use with this overlay
    [self.JKAnimatedViewInstance setOverlayBackgroundEffect:Transparent];
    self.JKAnimatedViewInstance.mainOptionsButtonTitle = @"Sexy Options";
    self.JKAnimatedViewInstance.mainOptionsButtonBackgroundImageName = @"gray.png";
    self.JKAnimatedViewInstance.optionButtonsDimension = 30;
    //These are default color parameters - User can change them before calling createAndSetupOverlayView method on foreground overlay view
    self.JKAnimatedViewInstance.optionsLabelTextColor = [UIColor whiteColor];
    
    //Create an actual view
    [self.JKAnimatedViewInstance createAndSetupOverlayView];
}

- (IBAction)openOptionsButtonPressed:(id)sender {
    [self.JKAnimatedViewInstance openOptionsView];
}


@end
