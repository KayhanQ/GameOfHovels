//
//  MapEncoder.m
//  GameOfHovels
//
//  Created by Kayhan Qaiser on 2015-04-03.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapEncoding.h"
#import "Map.h"
#import "Tile.h"
#import "Unit.h"


// creates an encoding for a Map for the start of a game
// assumes basic map has already been made
@implementation MapEncoding
{
    
}

- (id)init {
    if (self=[super init]) {
    }
    return self;
}

//structures max 3
//units
//villages
//players...

- (void)encodeMap:(Map *)map
{
    NSMutableArray* encoding = [NSMutableArray array];
    //array of array of structures per tile
    NSMutableArray* allStructures = [NSMutableArray array];
    NSMutableArray* units = [NSMutableArray array];
    NSMutableArray* villages = [NSMutableArray array];
    NSMutableArray* colors = [NSMutableArray array];

    for (Tile* t in map.tilesSprite) {
        NSMutableArray* structures = [NSMutableArray array];
        for (NSNumber* sType in [t getStructureTypes]) [structures addObject:sType];
        [allStructures addObject:structures];
        
        [units addObject:t.unit];
        if ([t isVillage]) [villages addObject:t.village];
        else [villages addObject:nil];
        
        [colors addObject:[NSNumber numberWithInt: t.pColor]];

    }
    [encoding addObject:allStructures];
    [encoding addObject:units];
    [encoding addObject:villages];
    [encoding addObject:colors];

    
    
}

- (Map*)decodeMap:(NSMutableArray*)encoding
{
    NSMutableArray* allStructures = [encoding objectAtIndex:0];
    NSMutableArray* units = [encoding objectAtIndex:1];
    NSMutableArray* villages = [encoding objectAtIndex:2];
    NSMutableArray* colors = [encoding objectAtIndex:3];
    
    Map* map = [[Map alloc] initWithBasicMap];
    
    for (int i = 0; i < map.tilesSprite.numChildren; i++) {
        Tile* t = (Tile*)[map.tilesSprite childAtIndex:i];
        
        for (NSNumber* sType in allStructures[i]) {
            if (sType == nil) continue;
            [t addStructure:[sType intValue]];
        }
        
        NSNumber* uType = units[i];
        if (uType != nil) [t addUnitWithType:[uType intValue]];
        NSNumber* vType = villages[i];
        if (vType != nil) [t addVillage:[vType intValue]];
        
        t.pColor = [colors[i] intValue];
        
    }

    
    return map;
}




@end