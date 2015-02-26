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
    CGFloat dimensionToConsider = MIN(self.view.frame.size.width, self.view.frame.size.height);
    self.expansionRadius = dimensionToConsider/2;
    self.numberOfOptions = 3;
    NSInteger maximumExpansionRadius = (self.expansionRadius - self.buttonDimension);
    if(self.expansionRadius > maximumExpansionRadius) {
        self.expansionRadius = maximumExpansionRadius;
    }
}

-(UIView*)getOverlayView {
    if(!self.overlayView) {
        self.overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.overlayView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        self.overlayView.alpha = 0.0;
        
        self.overlayShowHideButton = [[UIButton alloc] initWithFrame:self.openOptionsButton.frame];
        [self.overlayShowHideButton setBackgroundImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
        [self.overlayShowHideButton addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
        
        self.overlayShowHideButton.alpha = 0.0;
        [self.overlayView addSubview:self.overlayShowHideButton];
        
        
        //Add constraint to overlay shadow button
        self.overlayShowHideButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self matchXCenterOfView:self.overlayShowHideButton withXCenterOfView:self.overlayView andCommonAncestor:self.overlayView];
        
        
        NSLayoutConstraint* bottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.overlayShowHideButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20];
        
        [self addHeightAndWidthConstrainttoView:self.overlayShowHideButton withDimensionParameter:30];
        [self.overlayView addConstraint:bottomSpaceConstraint];
        
        
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeOverlayFromParentView:)];
        [self.overlayView addGestureRecognizer:tapRecognizer];
    }
    return self.overlayView;
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
    }];
}

- (IBAction)openOptionsButtonPressed:(UIButton*)sender {
    if(!self.isOptionsOpened) {
        
        [sender setBackgroundImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
        UIView* overlayView = [self getOverlayView];
        
        if(!self.optionButtonsHolder) {
            self.isOptionsOpened = !self.isOptionsOpened;
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
                UILabel* buttonTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, self.overlayShowHideButton.frame.size.height, self.overlayShowHideButton.frame.size.width, 20)];
                buttonTitle.text = [NSString stringWithFormat:@"%ld", (long)optionsCount];
                buttonTitle.textColor = [UIColor whiteColor];
                buttonTitle.textAlignment = NSTextAlignmentCenter;
                [button addSubview:buttonTitle];
                
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
            
            //Add constraint to overlayshowHideButton
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
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
