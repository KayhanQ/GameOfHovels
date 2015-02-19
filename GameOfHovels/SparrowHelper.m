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

+(void)centerPivot:(SPDisplayObject*)displayObject
{
    displayObject.pivotX = displayObject.width/2;
    displayObject.pivotY = displayObject.height/2;
}

@end