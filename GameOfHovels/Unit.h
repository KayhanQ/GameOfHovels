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
    enum UnitType {PEASANT = 1, INFANTRY, SOLDIER, RITTER, CANNON};
    enum WorkState {NOWORKSTATE = 0, BUILDINGMEADOW, BUILDINGROAD};
    enum AnimationType {IDLE = 0, CHOPPINGBAUM, BUILDING, ATTACKING};
    
    
    SPMovieClip* _idleMovie;
    SPMovieClip* _attackMovie;
    SPMovieClip* _walkMovie;
    SPMovieClip* _getHitMovie;

}


@property (nonatomic, readonly) int health;
@property (nonatomic, readonly) int strength;
@property (nonatomic, readonly) int buyCostWood;
@property (nonatomic, readonly) int buyCostGold;
@property (nonatomic, readonly) int upkeepCost;
@property (nonatomic, readonly) int upgradeCost;
@property (nonatomic) BOOL movable;
@property (nonatomic, readonly) int stamina;
@property (nonatomic) int distTravelled;

@property (nonatomic, readonly) enum UnitType uType;
@property (nonatomic) enum WorkState workState;

@property (nonatomic) BOOL workstateCompleted;


- (id)initWithUnitType: (enum UnitType) uType;
- (void)incrementWorkstate;
- (void)setWorkState:(enum WorkState)workState;
- (BOOL)canMoveToEnemyTile:(Tile*)tile;
- (BOOL)canChopBaum;
- (BOOL)canClearTombstone;
- (BOOL)tramplesMeadow;
- (void)transferPropertiesFrom:(Unit*)u;
- (void)endTurnUpdates;


@end