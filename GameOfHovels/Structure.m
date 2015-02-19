//
//  Structure.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 12/02/2015.
//
//

#import "Structure.h"

@implementation Structure {
    
}

@synthesize sType = _sType;


-(id)initWithStructureType:(enum StructureType)sType
{
    if (self=[super init]) {
        //custom code here
        _sType = sType;
        
        self.touchable = false;
    }
    return self;
}





@end
