//
//  TranslateWorldEvent.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 07/04/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "Tile.h"


#define EVENT_TYPE_TRANSLATE_WORLD @"translateWorld"


@interface TranslateWorldEvent : SPEvent

- (id)initWithType:(NSString *)type point:(SPPoint*)point;

@property (nonatomic, readonly) SPPoint* point;

@end