//
//  TranslateWorldEvent.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 07/04/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TranslateWorldEvent.h"

@implementation TranslateWorldEvent
{
}

@synthesize point = _point;

- (id)initWithType:(NSString *)type point:(SPPoint *)point
{
    if ((self = [super initWithType:type bubbles:YES]))
    {
        _point = point;
    }
    return self;
}

@end