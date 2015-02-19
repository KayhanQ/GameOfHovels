//
//  ActionMenu.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "ActionMenu.h"
#import "TileTouchedEvent.h"
#import "UnitEventMoveIntent.h"

@implementation ActionMenu {
    SPTexture *_baseTexture;
    SPImage *_baseImage;
    
    SPSprite* _buttonSprite;
    
    
}

@synthesize tile = _tile;

-(id)initWithTile:(Tile *)tile
{
    if (self=[super init]) {
        //custom code here
        
        _tile = tile;
        
        _buttonSprite = [SPSprite sprite];
        [self addChild:_buttonSprite];

    
        _baseTexture = [SPTexture textureWithContentsOfFile:@"tile_grass.png"];
        _baseImage = [SPImage imageWithTexture:_baseTexture];
        self.x = _tile.x;
        self.y = _tile.y-30;
        
        SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"button.png"];
        
        SPButton* moveButton = [SPButton buttonWithUpState:buttonTexture];
        moveButton.text = @"Upgrade Village";
        [moveButton addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [_buttonSprite addChild:moveButton];
        
    }
    return self;
}

- (void)onTouch:(SPTouchEvent*)event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"touchedButton");

        TileTouchedEvent* event = [[TileTouchedEvent alloc] initWithType:EVENT_TYPE_VILLAGE_UPGRADE_INTENT tile: _tile];
        [self dispatchEvent:event];
    }
}




@end
