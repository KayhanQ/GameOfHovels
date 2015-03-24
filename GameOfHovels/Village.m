//
//  Village.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Village.h"

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
        _woodPile = 40;
        _goldPile = 36;
        
        switch (vType) {
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

- (BOOL)isHigherThan:(Village *)v
{
    if (_vType >= v.vType) return true;
    return false;
}

@end

