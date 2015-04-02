//
//  Unit.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Unit.h"
#import "Tile.h"



@implementation Unit {
    SPTexture *_baseTexture;
    SPImage *_baseImage;
    
    int _turnsInWS;
    
}

//@synthesize tile = _tile;
@synthesize buyCostWood = _buyCostWood;
@synthesize buyCostGold = _buyCostGold;
@synthesize strength = _strength;
@synthesize uType = _uType;
@synthesize movable = _movable;
@synthesize stamina = _stamina;
@synthesize distTravelled = _distTravelled;
@synthesize workState = _workState;
@synthesize workstateCompleted = _workstateCompleted;
@synthesize upgradeCost = _upgradeCost;
@synthesize upkeepCost = _upkeepCost;

-(id)initWithUnitType:(enum UnitType)uType
{
    if (self=[super init]) {
        //custom code here'
        _uType = uType;
        _distTravelled = 0;
        _movable = true;
        _workstateCompleted = false;
        _upgradeCost = 10;
        _buyCostWood = 0;
        _buyCostGold = 0;
        
        switch (uType) {
            case PEASANT:
            {
                _strength = 1;
                _buyCostGold = 10;
                _upkeepCost = 2;
                _stamina = 1000;
                break;
                
            }
            case INFANTRY:
            {
                _strength = 2;
                _buyCostGold = 20;
                _upkeepCost = 6;
                _stamina = 1000;
                break;
            }
            case SOLDIER:
            {
                _strength = 3;
                _buyCostGold = 30;
                _upkeepCost = 18;
                _stamina = 1000;
                break;
            }
            case RITTER:
            {
                _strength = 4;
                _buyCostGold = 40;
                _upkeepCost = 54;
                _stamina = 1000;
                break;
            }
            case CANNON:
            {
                _strength = 3;
                _buyCostWood = 12;
                _buyCostGold = 35;
                _upkeepCost = 5;
                _stamina = 1;
                break;
            }
            default:
                break;
        }
        
        
        
        
        self.touchable = false;
    }
    return self;
}

//if you are in no workstate your completed is false
- (void)incrementWorkstate
{
    if (_workState == NOWORKSTATE) return;
        
    _turnsInWS++;
    
    switch (_workState) {
        case BUILDINGMEADOW:
        {
            if (_turnsInWS==3) _workstateCompleted = true;
            break;
        }
        case BUILDINGROAD:
        {
            if (_turnsInWS==2) _workstateCompleted = true;
            break;
        }
        default:
            break;
    }
}

- (void)setWorkState:(enum WorkState)workState
{
    _workState = workState;
    _workstateCompleted = false;
    _movable = false;
    
    if (_workState == NOWORKSTATE) {
        _movable = true;
        _turnsInWS = 0;
    }
}

- (BOOL)canMoveToEnemyTile:(Tile *)tile
{
    if (_uType == PEASANT || _uType == CANNON) return false;

    if ([tile hasUnit]) {
        if (tile.unit.strength >= self.strength) return false;
    }
    return true;
}

- (BOOL)canChopBaum
{
    BOOL possible = false;
    if (_uType == PEASANT || _uType == INFANTRY || _uType == SOLDIER) possible = true;
    return possible;
}

- (BOOL)canClearTombstone
{
    BOOL possible = false;
    if (_uType == PEASANT || _uType == INFANTRY || _uType == SOLDIER) possible = true;
    return possible;
}

- (BOOL)tramplesMeadow
{
    BOOL tramples = false;
    if (_uType == SOLDIER || _uType == RITTER || _uType == CANNON) tramples = true;
    return tramples;
}

- (void)transferPropertiesFrom:(Unit*)u
{
    _distTravelled += u.distTravelled;
}

- (void)endTurnUpdates
{
    [self incrementWorkstate];
    _distTravelled = 0;
}

@end
