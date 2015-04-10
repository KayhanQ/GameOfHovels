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
@synthesize playerId = _playerId;
@synthesize randomNumber = _randomNumber;
@synthesize hasLost = _hasLost;

- (id)initWithNumber:(int)number
{
    _pColor = number;
    _hasLost = false;
    return self;
}

- (NSComparisonResult)compare:(GamePlayer *)otherGamePlayer {
	NSNumber* myNumber = [NSNumber numberWithInt:self.randomNumber];
	NSNumber* otherNumber = [NSNumber numberWithInt:otherGamePlayer.randomNumber];
	return [myNumber compare:otherNumber];
}


@end