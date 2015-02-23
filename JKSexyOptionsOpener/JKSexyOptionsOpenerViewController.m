//
//  JKSexyOptionsOpenerViewController.m
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/22/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKSexyOptionsOpenerViewController.h"
#import "CustomSexyButton.h"

#define DEFAULT_ANIMATION_DURATION 0.5
#define LONGER_ANIMATION_DURATION 0.5

@interface JKSexyOptionsOpenerViewController ()
@property (assign) BOOL isOptionsOpened;
@property (strong) UIView* overlayView;
@property (weak, nonatomic) IBOutlet UIButton *openOptionsButton;
@property (strong) UIButton* overlayShowHideButton;
@property (assign) CGFloat expansionRadius;
@property (assign) NSInteger numberOfOptions;
@property (assign) NSInteger buttonDimension;
@property (strong) NSMutableArray* optionButtonsHolder;
@property (strong) NSTimer* timer;
@property (assign) NSInteger counter;

@end

@implementation JKSexyOptionsOpenerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isOptionsOpened = NO;
    self.buttonDimension = 30;
    self.expansionRadius = self.view.frame.size.width/2;
    self.numberOfOptions = 9;
    NSInteger maximumExpansionRadius = ((self.view.frame.size.width/2) - self.buttonDimension);
    if(self.expansionRadius > maximumExpansionRadius) {
        self.expansionRadius = maximumExpansionRadius;
    }
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                  target:self
                                                selector:@selector(closeOptions:)
                                                userInfo:nil
                                                 repeats:YES];
    
    
    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION delay:0.2* (self.numberOfOptions - 1)
         usingSpringWithDamping:0.7 initialSpringVelocity:5.0f
                        options:0 animations:^{
                            self.overlayShowHideButton.transform = CGAffineTransformMakeRotation(0);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
                                self.overlayView.alpha = 0.0;
                                self.overlayView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                            } completion:^(BOOL finished) {
                                [self.overlayView removeFromSuperview];
                            }];
                        }];
}

- (IBAction)openOptionsButtonPressed:(UIButton*)sender {
    if(!self.isOptionsOpened) {
       
        UIView* overlayView = [self getOverlayView];
        
        if(!self.optionButtonsHolder) {
            self.optionButtonsHolder = [NSMutableArray new];
            
            NSArray* anglesCollection = [self getAnglesCollectionFromNumberOfOptions];
            for(NSInteger optionsCount = 0; optionsCount < anglesCollection.count; optionsCount++) {
                CustomSexyButton* button = [[CustomSexyButton alloc] initWithFrame:self.overlayShowHideButton.frame];
                [button setBackgroundColor:[UIColor redColor]];
                button.identifier = optionsCount;
                CGFloat currentAngleValue = [anglesCollection[optionsCount] floatValue];
                button.offsetToApply = CGPointMake((_expansionRadius*sinf(currentAngleValue)), (-1 * _expansionRadius * cosf(currentAngleValue)));
                button.alpha = 0.0;
                [button setTitle:[NSString stringWithFormat:@"%d", optionsCount] forState:UIControlStateNormal];
                [self.overlayView addSubview:button];
                [self.optionButtonsHolder addObject:button];
            }
        }
        
        [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
            overlayView.alpha = 1.0;
            overlayView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [self.view addSubview:[self getOverlayView]];
        } completion:^(BOOL finished) {
            self.openOptionsButton.alpha = 0.0;
            self.overlayShowHideButton.alpha = 1.0;
            
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                          target:self
                                                        selector:@selector(openOptions:)
                                                        userInfo:nil
                                                         repeats:YES];
            
            [UIView animateWithDuration:0.2* (self.numberOfOptions - 1) delay:0
                 usingSpringWithDamping:0.35 initialSpringVelocity:5.0f
                                options:0 animations:^{
                                    self.overlayShowHideButton.transform = CGAffineTransformMakeRotation(M_PI);
                                } completion:nil];
            
        }];
    } else {
        [self removeOverlay];
    }
    self.isOptionsOpened = !self.isOptionsOpened;
}

-(NSArray*)getAnglesCollectionFromNumberOfOptions {
    
    NSMutableArray* anglesCollection = [NSMutableArray new];
    NSUInteger totalNumberOfElements = self.numberOfOptions;
    BOOL isOdd = (totalNumberOfElements%2 != 0);
    NSUInteger centerIndex = floor(totalNumberOfElements/2);
    NSUInteger angleScalingFactor = (2*(isOdd)? (totalNumberOfElements -1) : totalNumberOfElements);
    CGFloat angleFromCenter = (M_PI/ angleScalingFactor);
    NSInteger startIndex = centerIndex;
    
    if(totalNumberOfElements == 1) {
        [anglesCollection addObject:@0];
    }
    else {
        
        for(NSInteger counter = 0; counter<totalNumberOfElements; counter++) {
            if(counter == centerIndex && isOdd) {
                [anglesCollection addObject:@0];
            } else if (counter < centerIndex) {
                [anglesCollection addObject:@(-1*(startIndex--)*angleFromCenter)];
            } else {
                [anglesCollection addObject:@((startIndex++)*angleFromCenter)];
            }
            
            if(!startIndex) {
                startIndex = 1;
            }
            NSLog(@"start index %d",startIndex);
        }
    }
    return anglesCollection;
}

- (void)openOptions:(NSTimer *)timer {
    
    CustomSexyButton* individualButton = self.optionButtonsHolder[self.counter++];
    
        [UIView animateWithDuration:LONGER_ANIMATION_DURATION delay:0
             usingSpringWithDamping:0.5 initialSpringVelocity:5.0f
                            options:0 animations:^{
                                individualButton.alpha = 1.0;
                                individualButton.transform = CGAffineTransformMakeTranslation(individualButton.offsetToApply.x, individualButton.offsetToApply.y);
                            } completion:nil];
    
    if(self.counter >= [self.optionButtonsHolder count]) {
        self.counter -= 1;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)closeOptions:(NSTimer *)timer {
    
    CustomSexyButton* individualButton = self.optionButtonsHolder[self.counter--];
    
    [UIView animateWithDuration:LONGER_ANIMATION_DURATION delay:0
         usingSpringWithDamping:0.5 initialSpringVelocity:5.0f
                        options:0 animations:^{
                            individualButton.alpha = 0.0;
                            individualButton.transform = CGAffineTransformMakeTranslation(0, 0);
                        } completion:nil];
    
    if(self.counter < 0) {
        self.counter = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
