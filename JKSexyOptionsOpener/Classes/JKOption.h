//
//  JKOption.h
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/28/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JKOption : NSObject
@property (strong) NSString* title;
@property (strong) UIImage* backgroundImage;
-(instancetype)initWithTitle:(NSString*)optionTitle andImageName:(NSString*)imageName;
@end
