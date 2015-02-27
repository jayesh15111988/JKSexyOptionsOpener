//
//  CustomSexyButton.h
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/22/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSexyButton : UIButton
//Starts from 0 until total number of options - 1
@property (assign) NSUInteger identifier;
@property (assign) CGPoint offsetToApply;
//Check if current button is selected or not
@property (assign) BOOL isButtonSelected;
@end
