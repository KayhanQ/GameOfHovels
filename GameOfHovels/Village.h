//
//  Village.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "BasicSprite.h"

@class GamePlayer;

@interface Village : BasicSprite {
    
    enum VillageType {HOVEL = 1, TOWN, FORT};
    
}

//Village should have the player ID not the object 
@property (nonatomic) GamePlayer* player;
@property (nonatomic, readonly) enum VillageType vType;
@property (nonatomic) int woodPile;
@property (nonatomic) int goldPile;
@property (nonatomic) int cost;

- (id)initWithStructureType:(enum VillageType)vType;
- (BOOL)isSameAs:(Village*)v;
- (BOOL)isHigherThan:(Village*)v;
- (void)transferSuppliesFrom:(Village*)village;

@end