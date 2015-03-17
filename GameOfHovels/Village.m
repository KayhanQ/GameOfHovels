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

-(id)initWithStructureType:(enum VillageType)vType
{
    if (self=[super init]) {
        //custom code here
        _vType = vType;
        _woodPile = 40;
        _goldPile = 36;
        
        self.touchable = false;
    }
    return self;
}

@end

