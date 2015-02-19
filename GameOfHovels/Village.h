//
//  Village.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "BasicSprite.h"

@class GamePlayer;

@interface Village : BasicSprite {
    
    enum VillageType {HOVEL = 0, TOWN, FORT};
    
}

@property (nonatomic) GamePlayer* player;
@property (nonatomic, readonly) enum VillageType vType;

-(id)initWithStructureType:(enum VillageType)vType;


@end