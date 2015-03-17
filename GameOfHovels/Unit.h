//
//  Unit.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "Tile.h"
#import "BasicSprite.h"


@class Tile;

@interface Unit : BasicSprite {
    
    
    enum UnitType {PEASANT = 0, INFANTRY, SOLDIER, RITTER};
    enum WorkState {NOTHING = 0, BUILDINGMEADOW, BUILDINGROAD};
}


//@property (nonatomic, weak) Tile* tile;
@property (nonatomic, readonly) int health;
@property (nonatomic, readonly) int buyCost;
@property (nonatomic, readonly) int upkeepCost;
@property (nonatomic) BOOL movesCompleted;
@property (nonatomic, readonly) int stamina;
@property (nonatomic) int distTravelled;

@property (nonatomic, readonly) enum UnitType uType;
@property (nonatomic) enum WorkState workState;


-(id)initWithUnitType: (enum UnitType) uType;




@end