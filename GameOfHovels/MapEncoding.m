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
#import "MessageLayer.h"

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

- (NSString*)createPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* rootPath = paths[0];
    NSString* path = [rootPath stringByAppendingPathComponent:@"Saved_Games"];
    return path;
}

//format: p1ID, p1Color, p2ID, p2Color, p3ID, p3Color
//format: unit,village,color,s1,s2,s3
//We are not encoding players yet!
//will this be harcoded???
- (NSData*)encodeMap:(Map*)map
{
    NSMutableArray* encoding = [NSMutableArray array];
    NSNumber* minusOne = [NSNumber numberWithInt:-1];
	
	MessageLayer* messageLayer = [MessageLayer sharedMessageLayer];
	NSMutableArray* playerDataArray = [NSMutableArray array];
	for (GamePlayer* player in messageLayer.players) {
		[playerDataArray addObject: [NSNumber numberWithInt:[player.playerId intValue]]];
		[playerDataArray addObject: [NSNumber numberWithInt:player.pColor]];
	}

    for (Tile* t in map.tilesSprite) {
        NSMutableArray* tileArray = [NSMutableArray array];
        
        if ([t hasUnit]) [tileArray addObject:[NSNumber numberWithInt:t.unit.uType]];
        else [tileArray addObject:minusOne];
        
        if ([t isVillage]) [tileArray addObject:[NSNumber numberWithInt: t.village.vType]];
        else [tileArray addObject:minusOne];
        
        [tileArray addObject:[NSNumber numberWithInt: t.pColor]];
        
        int i = 0;
        for (NSNumber* number in [t getStructureTypes]) {
            [tileArray addObject:number];
        }
        
        [encoding addObject:tileArray];
    }

    NSMutableString* encodedString = [[NSMutableString alloc] init];
	
	int i = 0;
	for (NSNumber* number in playerDataArray) {
		NSString* numString = [number stringValue];
		[encodedString appendString: numString];
		if (i < playerDataArray.count-1) [encodedString appendString: @","];
		i++;
	}
    [encodedString appendLine:@""];

    for (NSMutableArray* tileArray in encoding) {
        int i = 0;
        for (NSNumber* number in tileArray) {
            NSString* numString = [number stringValue];
            [encodedString appendString: numString];
            if (i < tileArray.count-1) [encodedString appendString: @","];
            i++;
        }
        [encodedString appendLine:@""];
    }

    NSLog(@"%@",encodedString);
    
    NSData* dataBuffer = [encodedString dataUsingEncoding:NSUTF8StringEncoding];

    return dataBuffer;
}

- (void)saveMapWithData:(NSData*)data name:(NSString*)saveGameFileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* path = [self createPath];
    
    BOOL isDir;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", path);
    
    path = [path stringByAppendingPathComponent:saveGameFileName];
    path = [path stringByAppendingPathExtension:@"txt"];
    
    NSLog(@"path: %@", path);
    if ([fileManager fileExistsAtPath: path] == YES) {
        NSLog (@"File exists, overwrite");
    }
    else {
        NSLog (@"File not found, make a new one");
    }
    
    
    [fileManager createFileAtPath: path contents: data attributes: nil];
}


// In this method we will also have to tell message layer who the players are after we decode them
- (Map*)decodeMap:(NSData*)encoding
{
    NSString* encodingString = [[NSString alloc] initWithData:encoding encoding:NSUTF8StringEncoding];
    NSArray *linesArray = [encodingString componentsSeparatedByString: @"\n"];
    
    NSMutableArray* encodingArray = [NSMutableArray array];
	
	NSMutableArray* players = [NSMutableArray array];
	int i = 0;
    for (NSString* line in linesArray) {
		if (i == 0) {
			NSArray *playersDataArray = [line componentsSeparatedByString: @","];

			for (int j = 0; j<playersDataArray.count-1; j+=2) {
				NSNumber* colorNum = [playersDataArray objectAtIndex:j+1];
				NSNumber* idNum = [playersDataArray objectAtIndex:j];
				GamePlayer* p = [[GamePlayer alloc] initWithNumber: [colorNum intValue]];
				p.playerId = [NSString stringWithFormat:@"%d", [idNum intValue]];
				[players addObject:p];
			}
			
		}
		else {
			NSArray *tileArray = [line componentsSeparatedByString: @","];
			[encodingArray addObject:tileArray];
		}
		i++;
    }

	[MessageLayer sharedMessageLayer].players = players;
	
    Map* map = [[Map alloc] initWithBasicMap];

    for (int tileIndex = 0; tileIndex < encodingArray.count-1; tileIndex++) {
        NSArray* tileArray = [encodingArray objectAtIndex:tileIndex];
        Tile* tile = (Tile*)[map.tilesSprite childAtIndex:tileIndex];
		
        NSLog(@"count: %d", tileArray.count);

        int i = 0;
        for (NSNumber* number in tileArray) {
            int data = [number intValue];
            if (data == -1) {
                i++;
                continue;
            }
            if (i == 0) [tile addUnitWithType:data];
            if (i == 1) [tile addVillage:data];
            if (i == 2) {
                if ([[tileArray objectAtIndex:3] intValue] != SEA) {
                    [tile setPColor:data];
                }
            }
            if (i >= 3) {
                if ([[tileArray objectAtIndex:i] intValue] == SEA || [[tileArray objectAtIndex:i] intValue] == GRASS) {
                    i++;
                    continue;
                }
                [tile addStructure:data];
            }
            i++;
        }
    }
	
	[map assignPlayerInfoForLoadGame];
	
    return map;
}




@end