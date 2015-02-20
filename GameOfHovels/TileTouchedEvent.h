//
//  TileTouchedEvent.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "Tile.h"

#define EVENT_TYPE_TILE_TOUCHED @"tileTouched"
#define EVENT_TYPE_VILLAGE_UPGRADE_INTENT @"villageTouched"
#define EVENT_TYPE_UPGRADE_VILLAGE @"upgradeVillage"

#define EVENT_TYPE_UPGRADE_UNIT @"upgradeUnit"

@interface TileTouchedEvent : SPEvent

- (id)initWithType:(NSString *)type tile:(Tile*)tile;

@property (nonatomic, readonly) Tile* tile;

@end