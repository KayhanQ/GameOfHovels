//
//  UnitEvent.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//


#import <Foundation/Foundation.h>
@class Tile;


@interface UnitEvent : SPEvent
{

}

- (id)initWithType:(NSString *)type Tile:(Tile*)tile;

@property (nonatomic) Tile* tile;

@end