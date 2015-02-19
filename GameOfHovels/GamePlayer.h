//
//  GamePlayer.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>

@interface GamePlayer : NSObject {
    
}

@property (nonatomic) int woodPile;
@property (nonatomic) int goldPile;

@property (nonatomic) int color;

-(id)initWithString:(NSString*)name color:(int)color;



@end