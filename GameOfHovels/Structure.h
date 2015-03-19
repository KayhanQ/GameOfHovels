//
//  Structure.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 12/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "BasicSprite.h"

@class Tile;

@interface Structure : BasicSprite {

    enum StructureType {NONE = 0, GRASS, BAUM, TOMBSTONE, MEADOW};
    
}


-(id)initWithStructureType:(enum StructureType)sType;
@property (nonatomic, readonly) enum StructureType sType;




@end