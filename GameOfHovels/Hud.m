//
//  Hud.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hud.h"
#import "GHEvent.h"
#import "TranslateWorldEvent.h"
#import "SparrowHelper.h"
#import "Tile.h"
#import "Village.h"
#import "Map.h"
#import "MessageLayer.h"

@implementation Hud {
    
    SPSprite* _uiElementsSprite;
    SPButton*_quitButton;
    SPButton* _endTurnButton;
    SPButton* _saveGameButton;
    SPButton* _nextVillageButton;

    SPTextField* _woodField;
    SPTextField* _goldField;
    SPTextField* _healthField;
    SPTextField* _numTilesInRegion;

    Tile* _currentTile;
    
    MessageLayer* _messageLayer;
    
    int _yOffsetMinor;
    float _middleX;
    float _height;
    float _width;
}

@synthesize map = _map;

-(id)initWithMap:(Map *)map
{
    if (self=[super init]) {
        //custom code here
        
        _map = map;
        
        _messageLayer = [MessageLayer sharedMessageLayer];

        _height = Sparrow.stage.height;
        _width = 60;

        _yOffsetMinor = 3;
        
        
        SPQuad* background = [SPQuad quadWithWidth:_width height: _height];
        background.color = 0xcccccc;
        background.alpha = 0.4;
        [self addChild:background];
        
        _uiElementsSprite = [SPSprite sprite];
        [self addChild:_uiElementsSprite];
        
        _middleX = _width/2;

        
        _quitButton = [self newButton];
        _quitButton.text = @"Exit Game";
        _quitButton.y = _height - _quitButton.height;
        [_quitButton addEventListener:@selector(quitTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        
        _saveGameButton = [self newButton];
        _saveGameButton.text = @"Save Game";
        _saveGameButton.y = _quitButton.y - _saveGameButton.height;
        [_saveGameButton addEventListener:@selector(saveGameTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];

        _endTurnButton = [self newButton];
        _endTurnButton.text = @"End Turn";
        _endTurnButton.y = _saveGameButton.y - _endTurnButton.height;
        [_endTurnButton addEventListener:@selector(endTurnTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        
        _nextVillageButton = [self newButton];
        _nextVillageButton.text = @"Next Village";
        _nextVillageButton.y = _endTurnButton.y - _endTurnButton.height;
        [_nextVillageButton addEventListener:@selector(nextVillageTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        
        
        
        _healthField = [self newTextField];
        _healthField.text = @"Village Health: ";
        
        _numTilesInRegion = [self newTextField];
        _numTilesInRegion.text = @"Numb Tiles: ";
        
        _woodField = [self newTextField];
        _woodField.text = @"Wood: ";
        
        _goldField = [self newTextField];
        _goldField.text = @"Gold: ";
        

        
        [self arrangeUIElements];
    }
    return self;
}

- (void)arrangeUIElements
{
    float lastY = _height;
    int i = 0;
    for (SPDisplayObject* element in _uiElementsSprite) {
        element.x = _middleX;
        element.y = lastY - element.height/2;
        if (i == 4) element.y -= 20;
        lastY = element.y;
        i++;
    }
}

- (SPButton*)newButton
{
    SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"button.png"];
    SPButton* button = [SPButton buttonWithUpState:buttonTexture];
    [SparrowHelper centerPivot:button];
    button.x = _middleX;
    button.scale = 0.4;
    [_uiElementsSprite addChild:button];
    return button;
}

- (SPTextField*)newTextField
{
    SPTextField* t = [SPTextField textFieldWithWidth:_width height:15 text:@""];
    t.x = _middleX;
    t.border = false;
    t.fontSize = 5;
    [SparrowHelper centerPivot:t];
    [_uiElementsSprite addChild:t];
    return t;
}

- (void)update:(Tile *)tile
{
    _currentTile = tile;
    Village* v = tile.village;
    
    NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
    _woodField.text = woodString;
    
    NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
    _goldField.text = goldString;
    
    NSString* healthString = [NSString stringWithFormat:@"Village Health: %d", v.health];
    _healthField.text = healthString;
    
    int tCount = [_map getTilesforVillage:v].count;
    NSString* _numTilesInRegionString = [NSString stringWithFormat:@"Numb Tiles: %d", tCount];
    _numTilesInRegion.text = _numTilesInRegionString;
    
    
    //who is the unit and all its stats, workstate
    //if you click a village then put up how many tiles the village has
}

- (void)nextVillageTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSMutableArray* villageTiles = [_map getTilesWithMyVillages];
        Tile* tileToGoTo = nil;
        
        if (villageTiles == nil) return;
        
        tileToGoTo = [villageTiles objectAtIndex:0];
        for (int i = 0; i<villageTiles.count-1; i++) {
            Tile* vTile = [villageTiles objectAtIndex:i];
            if (_currentTile == vTile) {
                if (i == villageTiles.count-1) {
                    tileToGoTo = [villageTiles objectAtIndex:0];
                    break;
                }
                else {
                    tileToGoTo = [villageTiles objectAtIndex:i+1];
                    break;
                }
            }
        }
        _currentTile = tileToGoTo;
        
        if (_currentTile != nil) {
            SPPoint* localPoint = [SPPoint pointWithX:tileToGoTo.x y:tileToGoTo.y];
            TranslateWorldEvent* event = [[TranslateWorldEvent alloc] initWithType:EVENT_TYPE_TRANSLATE_WORLD point:localPoint];
            [self dispatchEvent:event];
        }
    }
}


- (void)endTurnTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"End turn pressed");
        GHEvent *event = [[GHEvent alloc] initWithType:EVENT_TYPE_TURN_ENDED];
        [self dispatchEvent:event];
    }
}

- (void)saveGameTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"End turn pressed");
        GHEvent *event = [[GHEvent alloc] initWithType:EVENT_TYPE_SAVE_GAME];
        [self dispatchEvent:event];
    }
}

- (void)quitTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"Quit Touched");
    }
}

@end