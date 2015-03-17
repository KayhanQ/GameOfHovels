//
//  GamePlayer.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>

@interface GamePlayer : NSObject {
    enum PlayerColor {NOCOLOR = 0, RED, BLUE, ORANGE};

}

@property (nonatomic, readonly) enum PlayerColor pColor;



-(id)initWithString:(NSString*)name color:(enum PlayerColor)pColor;



@end