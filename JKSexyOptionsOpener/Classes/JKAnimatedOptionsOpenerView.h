//
//  JKAnimatedOptionsOpenerView.h
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/27/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JKOPTION_BUTTON_TITLE @"title"
#define JKOPTION_BUTTON_IMAGE_NAME @"image"

typedef NS_OPTIONS(NSUInteger, OverlayViewBackgroundEffect){
    Transparent,
    Blurred
};

typedef void (^OptionSelected)(NSUInteger selectedOption);
typedef void (^OptionNotSelected)();

@interface JKAnimatedOptionsOpenerView : UIView

- (instancetype)initWithParentController:(UIViewController*)parentViewController andOptions:(NSArray*)options;
- (void)createAndSetupOverlayView;
- (void)openOptionsView;
- (void)setOverlayBackgroundEffect:(OverlayViewBackgroundEffect)backgroundEffect;
- (void)setExpansionRadiusWithValue:(CGFloat)expansionRadius;

@property (assign) OverlayViewBackgroundEffect overlayviewBackgroundEffect;
@property (strong, nonatomic) OptionSelected OptionSelectedBlock;
@property (strong, nonatomic) OptionNotSelected OptionNotSelectedBlock;

@property (strong) UIColor* optionsLabelTextColor;
@property (strong) UIFont* defaultTextFont;
@property (strong) UIColor* overlayBackgroundColor;

@property (strong) NSString* mainOptionsButtonTitle;
@property (strong) NSString* mainOptionsButtonBackgroundImageName;

@property (assign) NSInteger optionButtonsDimension;

@end
