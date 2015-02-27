//
//  JKSexyOptionsOpenerViewController.h
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/22/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OptionSelected)(NSUInteger optionSelected);
typedef void (^OperationCanceled)();

@interface JKSexyOptionsOpenerViewController : UIViewController

@property (strong, nonatomic) OptionSelected SelectedOptionBlock;
@property (strong, nonatomic) OperationCanceled OperationCancelBlock;

@end