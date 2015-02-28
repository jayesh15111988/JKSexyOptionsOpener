//
//  JKOption.m
//  JKSexyOptionsOpener
//
//  Created by Jayesh Kawli Backup on 2/28/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKOption.h"

@implementation JKOption

-(instancetype)initWithTitle:(NSString*)optionTitle andImageName:(NSString*)imageName {
    if(self = [super init]) {
        self.title = optionTitle;
        self.backgroundImage = [UIImage imageNamed:imageName];
    }
    return self;
}

@end
