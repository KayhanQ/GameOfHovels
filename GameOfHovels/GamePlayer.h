//
//  GamePlayer.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>

@interface GamePlayer : NSObject {
    enum PlayerColor {NOCOLOR = 0, RED, BLUE, ORANGE, GREY};
}

@property (nonatomic, readonly) enum PlayerColor pColor;
@property NSString* playerId;
@property long randomNumber;

-(id)initWithNumber:(int)number;



@end