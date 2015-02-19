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
    

    
}

//@synthesize tile = _tile;
@synthesize buyCost = _buyCost;
@synthesize uType = _uType;
@synthesize movesCompleted = _movesCompleted;
@synthesize stamina = _stamina;
@synthesize distTravelled = _distTravelled;
@synthesize workState = _workState;


-(id)initWithUnitType:(enum UnitType)uType
{
    if (self=[super init]) {
        //custom code here'
        _uType = uType;
        _distTravelled = 0;
        _movesCompleted = false;
        
        switch (uType) {
            case RITTER:
            {
                _buyCost = 50;
                _upkeepCost = 54;
                _stamina = 20;
                
            }
                break;
                
            default:
                break;
        }
        
        self.touchable = false;
        

    }
    return self;
}



@end
