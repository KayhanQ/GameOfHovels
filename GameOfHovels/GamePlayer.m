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

@synthesize woodPile = _woodPile;
@synthesize goldPile = _goldPile;

@synthesize color = _color;


- (id)initWithString:(NSString *)name color:(int)color
{
    _woodPile = 40;
    _goldPile = 36;
    
    _color = color;
    
    
    return self;
}


@end