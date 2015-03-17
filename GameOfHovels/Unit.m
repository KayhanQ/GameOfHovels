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
@synthesize buyCost = _buyCost;
@synthesize uType = _uType;
@synthesize movesCompleted = _movesCompleted;
@synthesize stamina = _stamina;
@synthesize distTravelled = _distTravelled;
@synthesize workState = _workState;
@synthesize workstateCompleted = _workstateCompleted;


-(id)initWithUnitType:(enum UnitType)uType
{
    if (self=[super init]) {
        //custom code here'
        _uType = uType;
        _distTravelled = 0;
        _movesCompleted = false;
        
        switch (uType) {
            case PEASANT:
            {
                _buyCost = 50;
                _upkeepCost = 54;
                _stamina = 20;
                break;
                
            }
            case RITTER:
            {
                _buyCost = 50;
                _upkeepCost = 54;
                _stamina = 20;
                
            }
            default:
                break;
        }
        
        
        _workstateCompleted = false;
        
        
        self.touchable = false;
        

    }
    return self;
}

//if you are in no workstate your completed is false
- (void)incrementWorkstate
{
    if (_workState != NOWORKSTATE) _turnsInWS++;

    _workstateCompleted = false;
    
    switch (_workState) {
        case BUILDINGMEADOW:
        {
            if (_turnsInWS<2) _workstateCompleted = false;
            break;
        }
        default:
            break;
    }
    
    if (_workstateCompleted == true) {
        _turnsInWS = 0;
    }
}


@end
