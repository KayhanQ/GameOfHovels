//
//  SparrowHelper.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "SparrowHelper.h"

@implementation SparrowHelper

@synthesize gameJuggler = _gameJuggler;

- (id)init
{
    if((self=[super init])) {
        _gameJuggler = [SPJuggler juggler];
    }
    return self;
}

+ (instancetype)sharedSparrowHelper
{
    static SparrowHelper *sharedSparrowHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSparrowHelper = [[SparrowHelper alloc] init];
    });
    return sharedSparrowHelper;
}

+ (void)centerPivot:(SPDisplayObject*)displayObject
{
    displayObject.pivotX = displayObject.width/2;
    displayObject.pivotY = displayObject.height/2;
}

@end