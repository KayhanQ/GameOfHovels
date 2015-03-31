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


}

@synthesize tile = _tile;
@synthesize buttonSprite = _buttonSprite;


-(id)initWithTile:(Tile *)tile
{
    if (self=[super init]) {
        //custom code here

        int _unitWoodCosts[] = {0,0,0,0,12};
        int _unitGoldCosts[] = {10,20,30,40,35};

        _tile = tile;
        
        _buttonSprite = [SPSprite sprite];
        [self addChild:_buttonSprite];
        

        
        if ([_tile isVillage]) {
            Village* village = _tile.village;

            int gold = village.goldPile;
            int wood = village.woodPile;
            
            if ([village canUpgrade]) {
                [self makeButton:UPGRADEVILLAGE];
            }
            
            if ([village canBuildTower]) {
                [self makeButton: BUILDTOWER];
            }
            
            
            if (gold >= _unitGoldCosts[0] || wood >= _unitWoodCosts[0]) {
                [self makeButton:BUYPEASANT];
            }
            //adds buttons from infantry upwards
            for (int i = 1; i<=village.vType; i++) {
                if (gold < _unitGoldCosts[i] || wood < _unitWoodCosts[i]) continue;
                [self makeButton:i+1];
            }
        }
        
        Unit* unit = tile.unit;
        
        if (unit != nil) {
            if (unit.uType == PEASANT && [tile canHaveMeadow]) [self makeButton:BUILDMEADOW];
            if (unit.uType == PEASANT && [tile canHaveRoad]) [self makeButton:BUILDROAD];
            if (unit.uType != CANNON) [self makeButton:UPGRADEUNIT];
            if (unit.uType == CANNON) [self makeButton:SHOOTCANNON];
        }

        
        [self arrangeButtons];
    }
    return self;
}

- (void)makeButton:(enum ActionType)aType
{
    ActionButton* b =[[ActionButton alloc] initWithActionType:aType tile:_tile];
    [SparrowHelper centerPivot:b];
    [_buttonSprite addChild:b];
}

- (void)arrangeButtons
{
    int xGap = 20;
    float index = 0;
    float count = _buttonSprite.numChildren;
    float angle = 2*PI/count;
    float radius = 65;
    
    for (SPDisplayObject* d in _buttonSprite) {
        
        d.x = _tile.x + cos(angle*index) * radius;
        d.y = _tile.y + sin(angle*index) * radius;
        /*
        d.x = _tile.x + index*(xGap + d.width);
        d.y = _tile.y - 40 - d.height/2;
         */
        index += 1;
    }
}




@end
