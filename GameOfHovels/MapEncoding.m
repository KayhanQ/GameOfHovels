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
//format: s1,s2,s3,u,v,c

- (void) encodeMap:(Map *)map
{
    NSMutableArray* encoding = [NSMutableArray array];
    //array of array of structures per tile
    NSMutableArray* allStructures = [NSMutableArray array];
    NSMutableArray* units = [NSMutableArray array];
    NSMutableArray* villages = [NSMutableArray array];
    NSMutableArray* colors = [NSMutableArray array];

    NSNumber* minusOne = [NSNumber numberWithInt:-1];
    
    for (Tile* t in map.tilesSprite) {
        NSMutableArray* structures = [NSMutableArray array];
        for (int i = 0; i < 3; i++) [structures addObject:minusOne];
        NSMutableArray* sTypes = [t getStructureTypes];
        for (int i = 0; i < sTypes.count-1; i++) {
            structures[i] = sTypes[i];
        }
        [allStructures addObject:structures];
        
        if ([t hasUnit]) [units addObject:t.unit];
        else [units addObject:minusOne];
        
        if ([t isVillage]) [villages addObject:t.village];
        else [villages addObject:minusOne];
        
        [colors addObject:[NSNumber numberWithInt: t.pColor]];

    }
    [encoding addObject:allStructures];
    [encoding addObject:units];
    [encoding addObject:villages];
    [encoding addObject:colors];

    
    
    
    NSString* stringToEncode = @"adlksjfhMEOWalskjdfha, 2,3,q54524562346,346256256,563243 asdflkh LKHD";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* rootPath = paths[0];
    NSString* path = [rootPath stringByAppendingPathComponent:@"Saved_Games"];
    
    BOOL isDir;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", path);
    
    path = [path stringByAppendingPathComponent:@"sg9"];
    path = [path stringByAppendingPathExtension:@"txt"];
    
    NSLog(@"path: %@", path);
    if ([fileManager fileExistsAtPath: path] == YES) {
        NSLog (@"File exists");
        NSData* databuffer = [fileManager contentsAtPath:path];
        NSString* dataString = [[NSString alloc] initWithData:databuffer encoding:NSUTF8StringEncoding];;
        NSLog(@"data: %@", dataString);
    }
    else {
        NSLog (@"File not found");
        NSData* dataBuffer = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
        [fileManager createFileAtPath: path contents: dataBuffer attributes: nil];

    }
}

- (Map*)decodeMap:(NSMutableArray*)encoding
{
    NSMutableArray* allStructures = [encoding objectAtIndex:0];
    NSMutableArray* units = [encoding objectAtIndex:1];
    NSMutableArray* villages = [encoding objectAtIndex:2];
    NSMutableArray* colors = [encoding objectAtIndex:3];
    
    NSNumber* minusOne = [NSNumber numberWithInt:-1];

    Map* map = [[Map alloc] initWithBasicMap];
    
    for (int i = 0; i < map.tilesSprite.numChildren; i++) {
        Tile* t = (Tile*)[map.tilesSprite childAtIndex:i];
        
        for (NSNumber* sType in allStructures[i]) {
            if (sType == minusOne) continue;
            [t addStructure:[sType intValue]];
        }
        
        NSNumber* uType = units[i];
        if (uType != minusOne) [t addUnitWithType:[uType intValue]];
        NSNumber* vType = villages[i];
        if (vType != minusOne) [t addVillage:[vType intValue]];
        
        t.pColor = [colors[i] intValue];
    }

    
    return map;
}




@end