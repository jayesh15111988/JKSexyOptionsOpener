//
//  JKSexyOptionsOpenerViewController.m
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/22/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKSexyOptionsOpenerViewController.h"
#define DEFAULT_ANIMATION_DURATION 0.5

@interface JKSexyOptionsOpenerViewController ()
@property (assign) BOOL isOptionsOpened;
@property (strong) UIView* overlayView;
@property (weak, nonatomic) IBOutlet UIButton *openOptionsButton;
@property (strong) UIButton* overlayShowHideButton;

@end

@implementation JKSexyOptionsOpenerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isOptionsOpened = NO;
}

-(UIView*)getOverlayView {
    if(!self.overlayView) {
        self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        self.overlayView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        self.overlayView.alpha = 0.0;
        
        self.overlayShowHideButton = [[UIButton alloc] initWithFrame:self.openOptionsButton.frame];
        [self.overlayShowHideButton setBackgroundImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
        [self.overlayShowHideButton addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
        self.overlayShowHideButton.alpha = 0.0;
        [self.overlayView addSubview:self.overlayShowHideButton];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeOverlayFromParentView:)];
        [self.overlayView addGestureRecognizer:tapRecognizer];
    }
    return _overlayView;
}

- (void)removeOverlayFromParentView:(UITapGestureRecognizer*)sender {
    [self removeOverlay];
}

-(void)removeOverlay {
    self.isOptionsOpened = !self.isOptionsOpened;
    self.overlayShowHideButton.alpha = 0.0;
    self.openOptionsButton.alpha = 1.0;
    [self.view addSubview:self.openOptionsButton];
    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
        self.overlayView.alpha = 0.0;
        self.overlayView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self.overlayView removeFromSuperview];
    }];
}

- (IBAction)openOptionsButtonPressed:(UIButton*)sender {
    if(!self.isOptionsOpened) {
        UIView* overlayView = [self getOverlayView];
        [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
            overlayView.alpha = 1.0;
            overlayView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [self.view addSubview:[self getOverlayView]];
        } completion:^(BOOL finished) {
            self.openOptionsButton.alpha = 0.0;
            self.overlayShowHideButton.alpha = 1.0;
        }];
    } else {
        [self removeOverlay];
    }
    self.isOptionsOpened = !self.isOptionsOpened;
}

@end
