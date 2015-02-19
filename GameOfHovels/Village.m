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

-(id)initWithStructureType:(enum VillageType)vType
{
    if (self=[super init]) {
        //custom code here
        _vType = vType;
        
        self.touchable = false;
    }
    return self;
}

@end

