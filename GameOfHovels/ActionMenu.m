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
#import "Media.h"
#import "SparrowHelper.h"
#import "ActionMenuEvent.h"
#import "ActionButton.h"


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
        
        if (tile.isVillage) {
            [self makeButton:UPGRADEVILLAGE];
            [self makeButton:BUYUNIT];

        }
        if (tile.unit != nil) {
            [self makeButton:BUILDMEADOW];
            [self makeButton:BUILDROAD];
        }

        
        [self arrangeButtons];
    }
    return self;
}

- (void)makeButton:(enum ActionType)aType
{
    ActionButton* b =[[ActionButton alloc] initWithActionType:aType tile:_tile];
    [_buttonSprite addChild:b];
}

- (void)arrangeButtons
{
    int xGap = 20;
    int index = 0;
    
    for (SPDisplayObject* d in _buttonSprite) {
        d.x = _tile.x + index*(xGap + d.width);
        d.y = _tile.y - 40 - d.height/2;
        index++;
    }
}




@end
