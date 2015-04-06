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

- (id)initWithNumber:(int)number
{
	switch(number)
	{
		case 0:
			_pColor = RED;
			break;
		case 1:
			_pColor = BLUE;
			break;
		case 2:
			_pColor = ORANGE;
			break;
		case 3:
			_pColor = GREY;
			break;
		default:
			_pColor = RED;
	}
    return self;
}

- (NSComparisonResult)compare:(GamePlayer *)otherGamePlayer {
	NSNumber* myNumber = [NSNumber numberWithInt:self.randomNumber];
	NSNumber* otherNumber = [NSNumber numberWithInt:otherGamePlayer.randomNumber];
	return [myNumber compare:otherNumber];
}


@end