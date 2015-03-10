//
//  ActionButton.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 21/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ActionButton.h"
#import "Media.h"
#import "SparrowHelper.h"
#import "Tile.h";

@implementation ActionButton {
    
}

@synthesize aType = _aType;
@synthesize tile = _tile;

-(id)initWithActionType:(enum ActionType)aType tile:(Tile *)tile
{
    if (self=[super init]) {
        //custom code here
        _aType = aType;
        _tile = tile;
        
        NSString* text;
        
        switch (aType) {
            case UPGRADEVILLAGE:
            {
                text = @"Upgrade Village";
                break;
            }
            case BUYUNIT:
            {
                text = @"Buy Unit";
                break;
            }
            case BUILDMEADOW:
            {
                text = @"Build Meadow";
                break;
            }
            case BUILDROAD:
            {
                text = @"Build ROAD";
                break;
            }
            default:
                break;
        }
        
        SPTexture* butTexture = [Media atlasTexture:@"tileLava_tile.png"];
        SPButton* button = [SPButton buttonWithUpState:butTexture];
        button.text = text;
        [SparrowHelper centerPivot:button];
        [self addChild:button];
        [self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];

        
        
        
    }
    return self;
}


- (void)onTouch:(SPTouchEvent*)event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"touchedButton");
        
        ActionMenuEvent* event = [[ActionMenuEvent alloc] initWithType:EVENT_TYPE_ACTION_MENU_ACTION tile:_tile actionType:_aType];
        [self dispatchEvent:event];
    }
}





@end