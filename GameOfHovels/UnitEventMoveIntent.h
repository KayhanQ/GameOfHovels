//
//  UnitEventMoveIntent.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "UnitEvent.h"

#define EVENT_TYPE_UNIT_MOVE_INTENT @"unitMoveIntent"

@interface UnitEventMoveIntent : UnitEvent

- (id)initWithType:(NSString *)type Tile:(Tile*)tile;


@end