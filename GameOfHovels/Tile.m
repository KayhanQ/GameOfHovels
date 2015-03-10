//
//  Tile.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Tile.h"
#import "TileTouchedEvent.h"

#import "Structure.h"
#import "Grass.h"
#import "Baum.h"
#import "Meadow.h"

#import "Hovel.h"
#import "Town.h"
#import "Fort.h"

#import "Media.h"


#import "SparrowHelper.h"


@implementation Tile {
    SPSprite* _structuresSprite;
    SPSprite* _villageSprite;

    Tile* topRightNeighbour;
    Tile* rightNeighbour;
    Tile* bottomRightNeighbour;

    SPImage* _tileLayer;
    
    NSMutableArray* _neighboursArray;
    //NSMutableArray* _structuresArray;

    NSTimer* _timer;
    

}

@synthesize baseImage = _baseImage;
@synthesize unit = _unit;
@synthesize color = _color;
@synthesize isVillage = _isVillage;
@synthesize village = _village;


-(id)initWithPosition:(SPPoint *)position structure:(enum StructureType)sType
{
    if (self=[super init]) {
        //custom code here
        
        _neighboursArray = [[NSMutableArray alloc] initWithCapacity:6];
        
        _unit = nil;
        _village = nil;
        _isVillage = false;
        

        
        _structuresSprite = [SPSprite sprite];
        _structuresSprite.x = self.width/2;
        _structuresSprite.y = self.height/2;
        [self addChild:_structuresSprite];
        
        //Tile needs some image to bw touched so we give it an 'empty' Tile
        //Right now this is a grass but eventually it will be white
        SPTexture* tileTexture = [Media atlasTexture:@"tileGrass_tile.png"];
        _tileLayer = [SPImage imageWithTexture:tileTexture];
        _tileLayer.alpha = 0.2;
        [SparrowHelper centerPivot:_tileLayer];
        [self addChild:_tileLayer];
        
        [self addStructure:sType];

        
        _villageSprite = [SPSprite sprite];
        [self addChild:_villageSprite];
        
        [SparrowHelper centerPivot:self];

        
        self.x = position.x;
        self.y = position.y;
        





        
        

        
        [self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        

    }
    return self;
}

//adds a physical village to the tile
-(void)addVillage:(enum VillageType) vType
{
    Hovel* h = [[Hovel alloc] initWithTile:self];
    [_villageSprite addChild:h];
    _village = h;
    
    _isVillage = true;
}

- (void)upgradeVillage
{
    Village* v = _village;

    Village* newVillage;
    switch (v.vType) {
        case HOVEL:
        {
            newVillage = [[Town alloc] initWithTile:self];
            break;
        }
        case TOWN:
        {
            newVillage = [[Fort alloc] initWithTile:self];
            break;
        }
        default:
        {
            return;
        }
    }
    [_villageSprite removeAllChildren];
    [_villageSprite addChild: newVillage];
    newVillage.player = v.player;
    _village = newVillage;
}

-(void)addStructure:(enum StructureType)sType
{
    switch (sType) {
        case GRASS: {
            Grass* g = [[Grass alloc] initWithTile:self];
            [_structuresSprite addChild:g];
            break;
        }
        case BAUM: {
            Baum* b = [[Baum alloc] initWithTile:self];
            [_structuresSprite addChild:b];
            break;
        }
        case MEADOW: {
            Meadow* m = [[Meadow alloc] initWithTile:self];
            [_structuresSprite addChild:m];
            break;
        }
            
        default:
            break;
    }
}

- (void)removeStructure
{
    Structure* s = [self getStructure];
    [s removeFromParent];
    
}

- (Structure*)getStructure
{
    return (Structure*)[_structuresSprite childAtIndex:_structuresSprite.numChildren-1];
}

- (enum StructureType)getStructureType
{
    Structure* s = [self getStructure];
    return s.sType;
}

- (void)setNeighbour:(int)tileNeighbour tile: (Tile*)tile
{
    [_neighboursArray insertObject:tile atIndex: (int)tileNeighbour];
}

- (Tile*)getNeighbour:(int)tileNeighbour
{
    Tile* t = [_neighboursArray objectAtIndex:tileNeighbour];
    return t;
}
- (NSMutableArray*)getNeighbours
{
    return _neighboursArray;
}

- (void)onTouch:(SPTouchEvent*)event
{
    SPTouch *touchBegan = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
    if (touchBegan) {
        //if the tile has a unit we can build a meadow
        if (_unit!=nil || _isVillage) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                      target:self
                                                    selector:@selector(showActionMenu:)
                                                    userInfo:nil
                                                     repeats:NO];
        }
    }
    
    SPTouch *touchEnded = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touchEnded)
    {
        [self invalidateTimer];
        
        TileTouchedEvent *event = [[TileTouchedEvent alloc] initWithType:EVENT_TYPE_TILE_TOUCHED tile:self];
        [self dispatchEvent:event];
    }
    
    SPTouch *touchCancelled = [[event touchesWithTarget:self andPhase:SPTouchPhaseCancelled] anyObject];
    if (touchCancelled)
    {
        [self invalidateTimer];
    }
}

//cancels timer
- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)showActionMenu:(NSTimer*)timer
{
    NSLog(@"Show action Menu");
    TileTouchedEvent *event = [[TileTouchedEvent alloc] initWithType:EVENT_TYPE_SHOW_ACTION_MENU tile:self];
    [self dispatchEvent:event];
}

- (BOOL)neighboursContainTile:(Tile*)tile
{
    for (Tile* nTile in _neighboursArray) {
        if (tile == nTile) return true;
    }
    return false;
}

-(BOOL)isTraversableForUnitType: (int)unitType
{
    enum StructureType sType = self.getStructureType;
    
    switch (sType) {
        case GRASS:
            return true;
        case BAUM:
        {
            if (unitType == RITTER) return false;
            else return true;
        }
        default:
            break;
    }
    return true;
    
}
- (BOOL)canHaveUnit
{
    if (_unit == nil && _isVillage == false && [self getStructureType] == GRASS) {
        return true;
    }
    return false;
}

- (BOOL)canHaveTree
{
    if (_unit == nil && _isVillage == false && [self getStructureType] == GRASS) {
        return true;
    }
    return false;
}

- (BOOL)canBeSelected
{
    if (_unit != nil) return true;
    //if (_isVillage) return true;

    return false;
}

- (void)setColor:(int)color
{
    _tileLayer.color = color;
}

- (void)selectTile
{
    _tileLayer.alpha = 0.5;
}

- (void)deselectTile
{
    _tileLayer.alpha = 0.2;
}

@end