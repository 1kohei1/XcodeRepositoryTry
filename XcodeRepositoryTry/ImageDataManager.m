//
//  ImageDataManager.m
//  XcodeRepositoryTry
//
//  Created by Kohei Arai on 9/10/14.
//  Copyright (c) 2014 Kohei Arai. All rights reserved.
//

#import "ImageDataManager.h"

@implementation ImageDataManager

- (NSArray *)getFoodImgName:(NSString *)recognizedCharacters {
    // match recognized characters to database
    return [[NSArray alloc]initWithObjects:recognizedCharacters, nil];
}

// method to match characters to menu items saved in database.

@end
