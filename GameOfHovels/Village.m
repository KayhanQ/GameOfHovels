//
//  Village.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Village.h"
#import "Unit.h"

@implementation Village
{
    
}

@synthesize vType = _vType;
@synthesize player = _player;
@synthesize woodPile = _woodPile;
@synthesize goldPile = _goldPile;
@synthesize cost = _cost;
@synthesize upkeep = _upkeep;
@synthesize health = _health;
@synthesize strength = _strength;

-(id)initWithStructureType:(enum VillageType)vType
{
    if (self=[super init]) {
        //custom code here
        _vType = vType;

        switch (_vType) {
            case HOVEL:
            {
                _cost = 0;
                _upkeep = 0;
                _health = 1;
                break;
                
            }
            case TOWN:
            {
                _cost = 8;
                _upkeep = 0;
                _health = 2;
                break;
            }
            case FORT:
            {
                _cost = 8;
                _upkeep = 0;
                _health = 5;
                _strength = 3;
                break;
            }
            case CASTLE:
            {
                _cost = 12;
                _upkeep = 80;
                _health = 10;
                _strength = 5;
                break;
            }
            default:
                break;
        }
        
        self.touchable = false;
    }
    return self;
}

- (BOOL)canSupportUnit:(Unit*)unit
{
    enum UnitType uType = unit.uType;
    BOOL canSupport = false;
    
    switch (_vType) {
        case HOVEL:
        {
            if (uType <= 2) canSupport = true;
            break;
        }
        case TOWN:
        {
            if (uType <= 3) canSupport = true;
            break;
        }
        case FORT:
        {
            if (uType <= 4) canSupport = true;
            break;
        }
        default:
            break;
    }
    
    return canSupport;
}

- (BOOL)canBeConqueredByUnit:(Unit*)unit;
{
    enum UnitType uType = unit.uType;
    BOOL canBeConquered = false;
    
    switch (_vType) {
        case HOVEL:
        {
            if (uType >= 3) canBeConquered = true;
            break;
        }
        case TOWN:
        {
            if (uType >= 3) canBeConquered = true;
            break;
        }
        case FORT:
        {
            if (uType >= 4) canBeConquered = true;
            break;
        }
        default:
            break;
    }
    
    return canBeConquered;
}

- (void)transferSuppliesFrom:(Village*)village
{
    _woodPile += village.woodPile;
    _goldPile += village.goldPile;
    _health += village.health;
    village.woodPile = 0;
    village.goldPile = 0;
    village.health = 0;
}

- (BOOL)isSameAs:(Village*)v
{
    if (self == v) return true;
    return false;
}

- (BOOL)protectsRegion
{
    if (_vType == FORT || _vType == CASTLE) return true;
    return false;
}

- (BOOL)isHigherThan:(Village *)v
{
    if (_vType > v.vType) return true;
    return false;
}

@end

