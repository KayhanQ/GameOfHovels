//
//  GamePlayer.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "GamePlayer.h"

@implementation GamePlayer
{
    
}

@synthesize pColor = _pColor;



- (id)initWithString:(NSString *)name color:(enum PlayerColor)pColor
{

    
    _pColor = pColor;
    
    
    return self;
}


@end