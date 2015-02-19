//
//  TileTouchedEvent.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "TileTouchedEvent.h"

@implementation TileTouchedEvent
{
    Tile* _tile;
}

@synthesize tile = _tile;

- (id)initWithType:(NSString *)type tile:(Tile *)tile
{
    if ((self = [super initWithType:type bubbles:YES]))
    {
        _tile = tile;
    }
    return self;
}

@end