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

-(id)initWithStructureType:(enum VillageType)vType
{
    if (self=[super init]) {
        //custom code here
        _vType = vType;

        switch (_vType) {
            case HOVEL:
            {
                _cost = 0;
                break;
                
            }
            case TOWN:
            {
                _cost = 8;
                break;
            }
            case FORT:
            {
                _cost = 8;
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
    village.woodPile = 0;
    village.goldPile = 0;
}

- (BOOL)isSameAs:(Village*)v
{
    if (self == v) return true;
    return false;
}

- (BOOL)isHigherThan:(Village *)v
{
    if (_vType >= v.vType) return true;
    return false;
}

@end

