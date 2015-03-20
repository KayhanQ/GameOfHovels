//
//  Unit.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "BasicSprite.h"


@class Tile;

@interface Unit : BasicSprite {
    enum UnitType {PEASANT = 0, INFANTRY, SOLDIER, RITTER};
    enum WorkState {NOWORKSTATE = 0, BUILDINGMEADOW, BUILDINGROAD};
}


@property (nonatomic, readonly) int health;
@property (nonatomic, readonly) int buyCost;
@property (nonatomic, readonly) int upkeepCost;
@property (nonatomic, readonly) int upgradeCost;
@property (nonatomic) BOOL movable;
@property (nonatomic, readonly) int stamina;
@property (nonatomic) int distTravelled;

@property (nonatomic, readonly) enum UnitType uType;
@property (nonatomic) enum WorkState workState;

@property (nonatomic) BOOL workstateCompleted;


-(id)initWithUnitType: (enum UnitType) uType;
-(void)incrementWorkstate;
-(void)setWorkState:(enum WorkState)workState;



@end