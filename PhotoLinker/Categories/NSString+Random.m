//
//  NSString+Random.m
//  PhotoLinker
//
//  Created by #50 on 10/24/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)

+ (NSString*)generateRandomStringWithNumber:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

@end
