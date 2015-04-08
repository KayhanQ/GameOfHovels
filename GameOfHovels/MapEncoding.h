//
//  Header.h
//  GameOfHovels
//
//  Created by Kayhan Qaiser on 2015-04-03.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//



@class Map;

@interface MapEncoding : NSObject {
    
}


- (id)init;
- (NSData*)encodeMap:(Map*)map;
- (void)saveMapWithData:(NSData*)data name:(NSString*)saveGameFileName;
- (Map*)decodeMap:(NSData*)encodedData;

@end
