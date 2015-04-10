//
//  GamePlayer.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>

@interface GamePlayer : NSObject {
    enum PlayerColor {NOCOLOR = 0, RED, BLUE, GREY, ORANGE};
}

@property (nonatomic) enum PlayerColor pColor;
@property (nonatomic) BOOL hasLost;
@property NSString* playerId;
@property long randomNumber;

-(id)initWithNumber:(int)number;



@end