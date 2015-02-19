//
//  UnitEvent.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "UnitEvent.h"

@implementation UnitEvent
{
}

@synthesize tile = _tile;

- (id)initWithType:(NSString *)type Tile:(Tile *)tile
{
    if ((self = [super initWithType:type bubbles:YES]))
    {
        _tile = tile;
    }
    return self;
}

@end