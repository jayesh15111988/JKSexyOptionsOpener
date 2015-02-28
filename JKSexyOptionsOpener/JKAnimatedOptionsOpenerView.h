//
//  JKAnimatedOptionsOpenerView.h
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/27/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, OverlayViewBackgroundEffect){
    TransparentBackgroundEffect,
    BlurredBackgroundEffect
};

typedef void (^OptionSelected)(NSUInteger optionSelected);
typedef void (^OperationCanceled)();

@interface JKAnimatedOptionsOpenerView : UIView

-(instancetype)initWithParentController:(UIViewController*)parentViewController;
-(void)createAndSetupOverlayView;
@property (assign) OverlayViewBackgroundEffect overlayviewBackgroundEffect;
@property (strong, nonatomic) OptionSelected SelectedOptionBlock;
@property (strong, nonatomic) OperationCanceled OperationCancelBlock;
- (void)openOptionsView;
@end
