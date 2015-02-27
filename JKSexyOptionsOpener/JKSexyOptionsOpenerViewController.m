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
#define LONGER_ANIMATION_DURATION 1.0

@interface JKSexyOptionsOpenerViewController ()
@property (assign) BOOL isOptionsOpened;
@property (strong) UIView* overlayView;
@property (weak, nonatomic) IBOutlet UIButton *openOptionsButton;
@property (strong, nonatomic) UIButton* topCloseOverlayButton;
@property (strong) UIButton* overlayShowHideButton;
@property (assign) CGFloat expansionRadius;
@property (assign) NSInteger numberOfOptions;
@property (strong) UIColor* optionsLabelTextColor;
@property (assign) NSInteger buttonDimension;
@property (strong) NSMutableArray* optionButtonsHolder;
@property (strong) NSTimer* timer;
@property (assign) NSInteger counter;
@property (strong) UIFont* defaultTextFont;
@property (strong) UIView* blurredView;

@end

@implementation JKSexyOptionsOpenerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isOptionsOpened = NO;
    self.buttonDimension = 30;
    self.overlayviewBackgroundEffect = TransparentBackgroundEffect;
    self.defaultTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    
    if(self.overlayviewBackgroundEffect == TransparentBackgroundEffect) {
        self.optionsLabelTextColor = [UIColor whiteColor];
    } else if (self.overlayviewBackgroundEffect == BlurredBackgroundEffect) {
        self.optionsLabelTextColor = [UIColor blackColor];
    }
    
    CGFloat dimensionToConsider = MIN(self.view.frame.size.width, self.view.frame.size.height);
    self.expansionRadius = dimensionToConsider/2;
    self.numberOfOptions = 3;
    NSInteger maximumExpansionRadius = (self.expansionRadius - (self.buttonDimension));
    if(self.expansionRadius > maximumExpansionRadius) {
        self.expansionRadius = maximumExpansionRadius;
    }
}

-(UIView*)getBlurredBackgroundView {
    if(!self.blurredView) {
        UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
        viewWithBlurredBackground.frame = self.view.frame;
    
        //UIVisualEffectView * viewInducingVibrancy = [[UIVisualEffectView alloc] initWithEffect:effect];
        //[viewWithBlurredBackground addSubview:viewInducingVibrancy];
        //UILabel * vibrantLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 50)];
        //vibrantLabel.text = @"Vibrancy and Blur Effects Simplified";
        //[viewInducingVibrancy addSubview:vibrantLabel];
        self.blurredView = viewWithBlurredBackground;
        self.blurredView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self.blurredView;
}

-(UIView*)getOverlayView {
    if(!self.overlayView) {
        self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        
        self.overlayView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        self.overlayView.alpha = 0.0;
        self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
        
        if(self.overlayviewBackgroundEffect == TransparentBackgroundEffect) {
            self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        } else if (self.overlayviewBackgroundEffect == BlurredBackgroundEffect) {
            [self.overlayView addSubview:[self getBlurredBackgroundView]];
        }
        
        self.overlayShowHideButton = [[UIButton alloc] initWithFrame:self.openOptionsButton.frame];
        [self.overlayShowHideButton setBackgroundImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
        [self.overlayShowHideButton addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
        
        self.overlayShowHideButton.alpha = 0.0;
        [self.overlayView addSubview:self.overlayShowHideButton];
        
        
        self.topCloseOverlayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.topCloseOverlayButton setBackgroundImage:[UIImage imageNamed:@"close-button.png"] forState:UIControlStateNormal];
        self.topCloseOverlayButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.topCloseOverlayButton addTarget:self action:@selector(removeOverlayFromTopCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.overlayView addSubview:self.topCloseOverlayButton];
        [self addHeightAndWidthConstrainttoView:self.topCloseOverlayButton withDimensionParameter:30];
        
        //Add top space constraint from super view
        NSLayoutConstraint* topSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.topCloseOverlayButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.overlayView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        
        //Add left space constraint from super view
        NSLayoutConstraint* leftSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.topCloseOverlayButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.overlayView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        
        //Add constraint to overlay shadow button
        self.overlayShowHideButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self matchXCenterOfView:self.overlayShowHideButton withXCenterOfView:self.overlayView andCommonAncestor:self.overlayView];
        
        
        NSLayoutConstraint* bottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.overlayShowHideButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:44];
        
        [self addHeightAndWidthConstrainttoView:self.overlayShowHideButton withDimensionParameter:30];
        [self.overlayView addConstraint:bottomSpaceConstraint];
        [self.overlayView addConstraint:topSpaceConstraint];
        [self.overlayView addConstraint:leftSpaceConstraint];
        
        
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeOverlayFromParentView:)];
        [self.overlayView addGestureRecognizer:tapRecognizer];
    }
    self.topCloseOverlayButton.transform = CGAffineTransformIdentity;
    return self.overlayView;
}


-(IBAction)removeOverlayFromTopCloseButton:(UIButton*)topCloseButton {
    //Add animation to top close button as soon as it is pressed
    [UIView animateWithDuration:1.0 animations:^{
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.1, 0.1);
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI);
        self.topCloseOverlayButton.transform = CGAffineTransformConcat(scaleTransform, rotationTransform);
    }];
    [self removeOverlay];
}

-(void)addHeightAndWidthConstrainttoView:(UIView*)inputView withDimensionParameter:(CGFloat)desiredDimension {
    
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:inputView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:desiredDimension];
    
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:inputView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:desiredDimension];
    [inputView addConstraints:@[heightConstraint, widthConstraint]];
}

- (void)removeOverlayFromParentView:(UITapGestureRecognizer*)sender {
    [self removeOverlay];
}

-(void)removeOverlay {
    self.isOptionsOpened = !self.isOptionsOpened;
    self.overlayShowHideButton.alpha = 0.0;
    self.openOptionsButton.alpha = 1.0;
    [self.openOptionsButton setBackgroundImage:[UIImage imageNamed:@"green.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:self.openOptionsButton];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.20
                                                  target:self
                                                selector:@selector(closeOptions:)
                                                userInfo:nil
                                                 repeats:YES];
    
    
    [UIView animateWithDuration:0.2*(self.numberOfOptions + 1) delay:0
         usingSpringWithDamping:0.7 initialSpringVelocity:5.0f
                        options:0 animations:^{
                            self.openOptionsButton.transform = CGAffineTransformMakeRotation(M_PI);
                        } completion:^(BOOL finished) {
        }];
    
    [UIView animateWithDuration:0.5 delay:0.2*(self.numberOfOptions + 1) options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.overlayView.alpha = 0.0;
        self.overlayView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self.overlayView removeFromSuperview];
        self.overlayShowHideButton.transform = CGAffineTransformMakeRotation(0);
        if(self.OperationCancelBlock) {
            self.OperationCancelBlock();
        }
    }];
}

- (IBAction)openOptionsButtonPressed:(UIButton*)sender {
    if(!self.isOptionsOpened) {
        
        [sender setBackgroundImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
        UIView* overlayView = [self getOverlayView];
        
        if(!self.optionButtonsHolder) {
            self.optionButtonsHolder = [NSMutableArray new];
            
            NSArray* anglesCollection = [self getAnglesCollectionFromNumberOfOptions];
            for(NSInteger optionsCount = 0; optionsCount < anglesCollection.count; optionsCount++) {
                CustomSexyButton* button = [[CustomSexyButton alloc] initWithFrame:self.overlayShowHideButton.frame];
                //[button setBackgroundColor:[UIColor redColor]];
            
                button.identifier = optionsCount;
                CGRect originalFrame = button.frame;
                originalFrame.size.height += 20;
                button.frame = originalFrame;
                button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                UILabel* buttonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-15, self.overlayShowHideButton.frame.size.height, 2 * self.overlayShowHideButton.frame.size.width, 30)];

                buttonTitleLabel.text = [NSString stringWithFormat:@"%ld", (long)optionsCount];

                buttonTitleLabel.textColor = self.optionsLabelTextColor;
                buttonTitleLabel.font = self.defaultTextFont;
                buttonTitleLabel.numberOfLines = 0;
                buttonTitleLabel.textAlignment = NSTextAlignmentCenter;
                [button addSubview:buttonTitleLabel];
                CGFloat currentAngleValue = [anglesCollection[optionsCount] floatValue];
                button.offsetToApply = CGPointMake((_expansionRadius*sinf(currentAngleValue)), (-1 * _expansionRadius * cosf(currentAngleValue)));
                button.alpha = 0.0;
                [button setImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
                //[button setTitle:[NSString stringWithFormat:@"%d", optionsCount] forState:UIControlStateNormal];
                button.translatesAutoresizingMaskIntoConstraints = NO;
                
                [self addHeightAndWidthConstrainttoView:button withDimensionParameter:30];
                [self.overlayView addSubview:button];
                [self matchXCenterOfView:button withXCenterOfView:self.overlayShowHideButton andCommonAncestor:self.overlayView];
                [self matchYCenterOfView:button withYCenterOfView:self.overlayShowHideButton andCommonAncestor:self.overlayView];
                
                [self.optionButtonsHolder addObject:button];
            }
        }
        
        [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
            overlayView.alpha = 1.0;
            overlayView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [self.view addSubview:[self getOverlayView]];
            
            [self addConstraintToView:self.overlayView relativeToSuperview:self.view withTopOffset:20.0];
            
            if(self.overlayviewBackgroundEffect == BlurredBackgroundEffect) {
                [self addConstraintToView:self.blurredView relativeToSuperview:self.overlayView withTopOffset:0.0];
            }
            
            //self.view.translatesAutoresizingMaskIntoConstraints = NO;
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
                                } completion:^(BOOL finished) {
                                    self.openOptionsButton.transform = CGAffineTransformIdentity;
                                }];
            
        }];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"green.png"] forState:UIControlStateNormal];
        [self removeOverlay];
    }
    self.isOptionsOpened = !self.isOptionsOpened;
}

-(void)addConstraintToView:(UIView*)childView relativeToSuperview:(UIView*)parentView withTopOffset:(CGFloat)topOffset {
    //Add constraint to overlayshowHideButton
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:topOffset]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
}

-(IBAction)buttonSelected:(CustomSexyButton*)sexyOptionsButton {
    [UIView animateKeyframesWithDuration:1.0 delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(sexyOptionsButton.offsetToApply.x, sexyOptionsButton.offsetToApply.y -40);
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.1, 1.1);
            sexyOptionsButton.transform = CGAffineTransformConcat(translationTransform, scaleTransform);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:1.0 animations:^{
            CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(sexyOptionsButton.offsetToApply.x,sexyOptionsButton.offsetToApply.y);
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.0, 1.0);
            sexyOptionsButton.transform = CGAffineTransformConcat(translationTransform, scaleTransform);
        }];
        
    } completion:^(BOOL finished) {
        [self removeOverlay];
        if(self.SelectedOptionBlock) {
            sexyOptionsButton.isButtonSelected = YES;
            self.SelectedOptionBlock(sexyOptionsButton.identifier);
        }
    }];
}

-(void)matchXCenterOfView:(UIView*)childView withXCenterOfView:(UIView*)parentView andCommonAncestor:(UIView*)ancestor{
    NSLayoutConstraint* matchingXCenterConstraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [ancestor addConstraint:matchingXCenterConstraint];
}

-(void)matchYCenterOfView:(UIView*)childView withYCenterOfView:(UIView*)parentView andCommonAncestor:(UIView*)ancestor{
    NSLayoutConstraint* matchingYCenterConstraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [ancestor addConstraint:matchingYCenterConstraint];
}

-(NSArray*)getAnglesCollectionFromNumberOfOptions {
    
    NSMutableArray* anglesCollection = [NSMutableArray new];
    NSUInteger totalNumberOfElements = self.numberOfOptions;
    BOOL isOdd = (totalNumberOfElements%2 != 0);
    NSUInteger centerIndex = floor(totalNumberOfElements/2);
    NSUInteger angleScalingFactor = ((2*(isOdd))? (totalNumberOfElements -1) : totalNumberOfElements);
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
            NSLog(@"start index %ld",(long)startIndex);
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
