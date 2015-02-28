//
//  JKAnimatedOptionsOpenerView.m
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/27/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKAnimatedOptionsOpenerView.h"
#import "CustomSexyButton.h"

#define SMALL_ANIMATION_DURATION 0.2
#define MEDIUM_ANIMATION_DURATION 0.6
#define LONGER_ANIMATION_DURATION 1.0

#define DEFAULT_LABEL_WIDTH 60

@interface JKAnimatedOptionsOpenerView ()

@property (assign) BOOL isOptionsOpened;
@property (strong) UIView* overlayView;
@property (strong, nonatomic) UIButton* topCloseOverlayButton;
@property (strong) UIButton* overlayShowHideButton;
@property (strong) NSMutableArray* optionButtonsHolder;
@property (strong) NSTimer* timer;
@property (assign) NSInteger counter;
@property (strong) UIView* blurredView;
@property (strong) UIViewController* parentController;
@property (strong) NSArray* optionsCollection;
@property (assign) NSInteger numberOfOptions;
@property (assign) CGFloat expansionRadius;

@end

@implementation JKAnimatedOptionsOpenerView

-(instancetype)initWithParentController:(UIViewController*)parentViewController andOptions:(NSArray *)options {
    
    //Setting up default parameters first which can then be overriden by the user
    self.parentController = parentViewController;
    self.isOptionsOpened = NO;
    self.optionButtonsDimension = 30;
    self.overlayviewBackgroundEffect = Blurred;
    self.defaultTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    self.optionsLabelTextColor = [UIColor blackColor];
    self.optionsCollection = options;
    self.numberOfOptions = self.optionsCollection.count;
    NSAssert(self.numberOfOptions > 0, @"Number Of options must be positive number");
    self.overlayBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    CGFloat dimensionToConsider = MIN(self.parentController.view.frame.size.width, self.parentController.view.frame.size.height);
    self.mainOptionsButtonBackgroundImageName = @"yellow.png";
    self.mainOptionsButtonTitle = @"Main";
    
    [self setExpansionRadiusWithValue:dimensionToConsider];
    return self;
}

- (void)setExpansionRadiusWithValue:(CGFloat)expansionRadius {
    self.expansionRadius = expansionRadius/2;
    NSInteger maximumExpansionRadius = (self.expansionRadius - self.optionButtonsDimension);
    if(self.expansionRadius > maximumExpansionRadius) {
        self.expansionRadius = maximumExpansionRadius;
    }
}

- (void)setOverlayBackgroundEffect:(OverlayViewBackgroundEffect)backgroundEffect {
    self.overlayviewBackgroundEffect = backgroundEffect;
    if(backgroundEffect == Transparent) {
        self.optionsLabelTextColor = [UIColor whiteColor];
    } else if (backgroundEffect == Blurred) {
        self.optionsLabelTextColor = [UIColor blackColor];
    }
}

-(void)createAndSetupOverlayView {
    [self createOverlayView];
    [self.parentController.view addSubview:self.overlayView];
    [self addConstraintToView:self.overlayView relativeToSuperview:self.parentController.view withTopOffset:20.0];
    
    if(self.overlayviewBackgroundEffect == Blurred) {
        [self addConstraintToView:self.blurredView relativeToSuperview:self.overlayView withTopOffset:0.0];
    }
}

-(void)createOverlayView {
    if(!self.overlayView) {
        self.overlayView = [[UIView alloc] initWithFrame:self.parentController.view.frame];
        
        self.overlayView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        self.overlayView.alpha = 0.0;
        self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
        
        if(self.overlayviewBackgroundEffect == Transparent) {
            self.overlayView.backgroundColor = self.overlayBackgroundColor;
        } else if (self.overlayviewBackgroundEffect == Blurred) {
            [self.overlayView addSubview:[self getBlurredBackgroundView]];
        }
        
        self.overlayShowHideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.optionButtonsDimension, self.optionButtonsDimension)];
        [self.overlayShowHideButton setBackgroundImage:[UIImage imageNamed:self.mainOptionsButtonBackgroundImageName] forState:UIControlStateNormal];
        [self.overlayShowHideButton addTarget:self action:@selector(removeOverLayWithAnimation) forControlEvents:UIControlEventTouchUpInside];
        self.overlayShowHideButton.alpha = 0.0;
        self.overlayShowHideButton.titleLabel.font = self.defaultTextFont;
        
        UILabel* mainButtonTitleLabel = [self createAndGetLabelForOptionsButtonWithFrame:CGRectMake(self.overlayShowHideButton.frame.origin.x, self.overlayShowHideButton.frame.origin.y + self.overlayShowHideButton.frame.size.height, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_WIDTH/2) andText:self.mainOptionsButtonTitle];
        
        mainButtonTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.overlayView addSubview:self.overlayShowHideButton];
        [self.overlayView addSubview:mainButtonTitleLabel];
        
        
        [self addTopSpacingConstraintWithTopView:self.overlayShowHideButton andBottomView:mainButtonTitleLabel andCommonAncestor:self.overlayView];
        
        
        self.topCloseOverlayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_LABEL_WIDTH/2, DEFAULT_LABEL_WIDTH/2)];
        [self.topCloseOverlayButton setBackgroundImage:[UIImage imageNamed:@"close-button.png"] forState:UIControlStateNormal];
        self.topCloseOverlayButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.topCloseOverlayButton addTarget:self action:@selector(removeOverlayFromTopCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.overlayView addSubview:self.topCloseOverlayButton];
        [self addHeightAndWidthConstrainttoView:self.topCloseOverlayButton withHeightParameter:30 andWidthParameter:30];
        
        //Add top space constraint from super view
        NSLayoutConstraint* topSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.topCloseOverlayButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.overlayView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        
        //Add left space constraint from super view
        NSLayoutConstraint* leftSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.topCloseOverlayButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.overlayView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
        
        //Add constraint to overlay shadow button
        self.overlayShowHideButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self matchXCenterOfView:self.overlayShowHideButton withXCenterOfView:self.overlayView andCommonAncestor:self.overlayView];
        
        
        NSLayoutConstraint* bottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.overlayShowHideButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:44];
        
        [self addHeightAndWidthConstrainttoView:self.overlayShowHideButton withHeightParameter:30 andWidthParameter:30];
        [self.overlayView addConstraint:bottomSpaceConstraint];
        [self.overlayView addConstraint:topSpaceConstraint];
        [self.overlayView addConstraint:leftSpaceConstraint];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeOverlayFromParentView:)];
        [self.overlayView addGestureRecognizer:tapRecognizer];
    }
}

-(void)addTopSpacingConstraintWithTopView:(UIView*)topView andBottomView:(UIView*)bottomView andCommonAncestor:(UIView*)commonAncestor {
    
    [self matchXCenterOfView:bottomView withXCenterOfView:topView andCommonAncestor:commonAncestor];
    [self addHeightAndWidthConstrainttoView:bottomView withHeightParameter:bottomView.frame.size.height andWidthParameter:bottomView.frame.size.width];
    [self.overlayView addConstraint:[NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
}

-(IBAction)removeOverlayFromTopCloseButton:(UIButton*)topCloseButton {
    //Add animation to top close button as soon as it is pressed
    
    [UIView animateWithDuration:MEDIUM_ANIMATION_DURATION animations:^{
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.1, 0.1);
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI);
        self.topCloseOverlayButton.transform = CGAffineTransformConcat(scaleTransform, rotationTransform);
    } completion:^(BOOL finished) {
        [self removeOverLayWithAnimation];
    }];
}

-(void)removeOverLayWithAnimation {
    [self removeOverlayWithDelay:0 andCompletion:^{
        if(self.OptionNotSelectedBlock) {
            self.OptionNotSelectedBlock();
        }
    }];
}

- (void)removeOverlayFromParentView:(UITapGestureRecognizer*)sender {
    [self removeOverlayWithDelay:0 andCompletion:^{
        if(self.OptionNotSelectedBlock) {
            self.OptionNotSelectedBlock();
        }
    }];
}

-(UIView*)getBlurredBackgroundView {
    if(!self.blurredView) {
        UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
        viewWithBlurredBackground.frame = self.parentController.view.frame;
        self.blurredView = viewWithBlurredBackground;
        self.blurredView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self.blurredView;
}

-(void)removeOverlayWithDelay:(NSTimeInterval)animationDelay andCompletion:(void (^)())completion {
    
    self.isOptionsOpened = !self.isOptionsOpened;
    self.overlayShowHideButton.alpha = 1.0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:animationDelay
                                                  target:self
                                                selector:@selector(closeOptions:)
                                                userInfo:nil
                                                 repeats:YES];
    
    
    [UIView animateWithDuration:animationDelay*(self.numberOfOptions + 1) delay:0
         usingSpringWithDamping:0.7 initialSpringVelocity:5.0f
                        options:0 animations:^{
                            self.overlayShowHideButton.transform = CGAffineTransformMakeRotation(0);
                        } completion:^(BOOL finished) {
                        }];
    
    [UIView animateWithDuration:0.5 delay:animationDelay*(self.numberOfOptions + 1) options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.overlayView.alpha = 0.0;
        self.overlayView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [self.overlayView removeFromSuperview];
        self.overlayShowHideButton.transform = CGAffineTransformMakeRotation(0);
        if(completion != nil) {
            completion();
        }
    }];
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


-(void)addHeightAndWidthConstrainttoView:(UIView*)inputView withHeightParameter:(CGFloat)height andWidthParameter:(CGFloat)width {
    
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:inputView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:height];
    
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:inputView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:width];
    [inputView addConstraints:@[heightConstraint, widthConstraint]];
}


-(void)matchXCenterOfView:(UIView*)childView withXCenterOfView:(UIView*)parentView andCommonAncestor:(UIView*)ancestor{
    NSLayoutConstraint* matchingXCenterConstraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [ancestor addConstraint:matchingXCenterConstraint];
}

-(void)matchYCenterOfView:(UIView*)childView withYCenterOfView:(UIView*)parentView andCommonAncestor:(UIView*)ancestor{
    NSLayoutConstraint* matchingYCenterConstraint = [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [ancestor addConstraint:matchingYCenterConstraint];
}

-(void)addConstraintToView:(UIView*)childView relativeToSuperview:(UIView*)parentView withTopOffset:(CGFloat)topOffset {
    //Add constraint to overlayshowHideButton
    [self.parentController.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:topOffset]];
    
    [self.parentController.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.parentController.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.parentController.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:parentView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)openOptionsView {
    
    if(!self.isOptionsOpened) {
     self.topCloseOverlayButton.transform = CGAffineTransformIdentity;
     
     if(!self.optionButtonsHolder) {
         self.optionButtonsHolder = [NSMutableArray new];
     
         NSArray* anglesCollection = [self getAnglesCollectionFromNumberOfOptions];
         for(NSInteger optionsCount = 0; optionsCount < anglesCollection.count; optionsCount++) {
             CustomSexyButton* button = [[CustomSexyButton alloc] initWithFrame:self.overlayShowHideButton.frame];
             button.identifier = optionsCount;
             JKOption* currentOptionObject = self.optionsCollection[optionsCount];
             //[button setBackgroundColor:[UIColor greenColor]];
             CGRect originalFrame = button.frame;
             originalFrame.size.height += 20;
             button.frame = originalFrame;
             button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
             UILabel* buttonTitleLabel = [self createAndGetLabelForOptionsButtonWithFrame:CGRectMake(-(DEFAULT_LABEL_WIDTH/2) + (self.optionButtonsDimension/2), self.optionButtonsDimension + 5, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_WIDTH/2) andText:currentOptionObject.title];
             [button addSubview:buttonTitleLabel];
             //[buttonTitleLabel setBackgroundColor:[UIColor redColor]];
             CGFloat currentAngleValue = [anglesCollection[optionsCount] floatValue];
             button.offsetToApply = CGPointMake((_expansionRadius*sinf(currentAngleValue)), (-1 * _expansionRadius * cosf(currentAngleValue)));
             button.alpha = 0.0;
             [button setImage:currentOptionObject.backgroundImage forState:UIControlStateNormal];
             [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
             button.translatesAutoresizingMaskIntoConstraints = NO;
             [self addHeightAndWidthConstrainttoView:button withHeightParameter:self.optionButtonsDimension andWidthParameter:self.optionButtonsDimension];
             [self.overlayView addSubview:button];
             [self matchXCenterOfView:button withXCenterOfView:self.overlayShowHideButton andCommonAncestor:self.overlayView];
             [self matchYCenterOfView:button withYCenterOfView:self.overlayShowHideButton andCommonAncestor:self.overlayView];
             [self.optionButtonsHolder addObject:button];
         }
     }
     
     [UIView animateWithDuration:MEDIUM_ANIMATION_DURATION animations:^{
         self.overlayView.alpha = 1.0;
         self.overlayView.transform = CGAffineTransformMakeScale(1.0, 1.0);
         [self.parentController.view addSubview:self.overlayView];
         [self addConstraintToView:self.overlayView relativeToSuperview:self.parentController.view withTopOffset:20.0];
     
         if(self.overlayviewBackgroundEffect == Blurred) {
             [self addConstraintToView:self.blurredView relativeToSuperview:self.overlayView withTopOffset:0.0];
         }
     } completion:^(BOOL finished) {
         self.overlayShowHideButton.alpha = 1.0;
         self.timer = [NSTimer scheduledTimerWithTimeInterval:SMALL_ANIMATION_DURATION target:self selector:@selector(openOptions:) userInfo:nil repeats:YES];
         [UIView animateWithDuration:SMALL_ANIMATION_DURATION * (self.numberOfOptions - 1) delay:0
              usingSpringWithDamping:0.35 initialSpringVelocity:5.0f
                             options:0 animations:^{
                                 self.overlayShowHideButton.transform = CGAffineTransformMakeRotation(M_PI);
                             } completion:^(BOOL finished) {
                             }];
        }];
     } else {
         [self removeOverlayWithDelay:0 andCompletion:^{
             if(self.OptionNotSelectedBlock) {
                 self.OptionNotSelectedBlock();
             }
         }];
     }
     self.isOptionsOpened = !self.isOptionsOpened;
}

-(UILabel*)createAndGetLabelForOptionsButtonWithFrame:(CGRect)labelFrame andText:(NSString*)labelText {
    UILabel* buttonTitleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    buttonTitleLabel.text = labelText;
    buttonTitleLabel.textColor = self.optionsLabelTextColor;
    buttonTitleLabel.font = self.defaultTextFont;
    buttonTitleLabel.numberOfLines = 0;
    buttonTitleLabel.textAlignment = NSTextAlignmentCenter;
    return buttonTitleLabel;
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
        [self removeOverlayWithDelay:SMALL_ANIMATION_DURATION andCompletion:^{
            if(self.OptionSelectedBlock) {
                self.OptionSelectedBlock(sexyOptionsButton.identifier);
            }
        }];
    }];
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
        }
    }
    return anglesCollection;
}

@end
