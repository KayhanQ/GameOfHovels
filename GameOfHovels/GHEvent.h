//
//  GHEvent.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EVENT_TYPE_TURN_ENDED @"turnEnded"

@interface GHEvent : SPEvent

- (id)initWithType:(NSString *)type;


@end