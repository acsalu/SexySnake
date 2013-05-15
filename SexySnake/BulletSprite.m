//
//  BulletSprite.m
//  SexySnake
//
//  Created by LCR on 5/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BulletSprite.h"
#import "GameLayer.h"
#import "SSSnake.h"

@implementation BulletSprite

+ (BulletSprite *)bulletWithPositionInGrid:(Grid *)grid andDirection:(Direction)direction
{
    BulletSprite *bullet = [BulletSprite spriteWithFile:@"bullet4.png"];
    bullet.positionInGrid = grid;
    bullet.position = [Grid positionWithGrid:grid];
    bullet.rotation = (direction - 1) * 90;
    bullet.direction = direction;
    
    return bullet;
    
}

- (void)setDelegate:(GameLayer<BulletSpriteDelegate> *)delegate
{
    _delegate = delegate;
    _mySnake = delegate.mySnake;
    _otherSnake = delegate.otherSnake;
    _map = delegate.map;
}

- (void)fire
{
    [self updatePosition];
}

- (void)updatePosition
{
    Grid *nextGrid = [Grid gridForDirection:_direction toGrid:_positionInGrid];

    if (nextGrid != nil) {

        Item itemInNextGrid =  [_map.mapInfo[nextGrid.row][nextGrid.col] intValue];

        if (itemInNextGrid == EMPTY) {
            id movement = [CCMoveTo actionWithDuration:0.03 position:[Grid positionWithGrid:nextGrid]];
            id callback = [CCCallFunc actionWithTarget:self selector:@selector(updatePosition)];
            CCSequence *sequence = [CCSequence actions:movement, callback, nil];
            [self runAction:sequence];
            
            _positionInGrid = nextGrid;
            
        } else if (itemInNextGrid == TARGET) {
            [self removeFromParentAndCleanup:YES];
            // kill target
            [_map removeTargetAt:nextGrid];
            
        } else if (itemInNextGrid == BULLET) {
//            [self removeFromParentAndCleanup:YES];
            // kill bullet
        } else if (itemInNextGrid == WALL) {
            [self removeFromParentAndCleanup:YES];
            // suicide
        } else if (itemInNextGrid == BULLETTARGET) {
            [self removeFromParentAndCleanup:YES];
            [_map removeBulletTargetAt:nextGrid];
            // kill bullet target
        } else { // snake
            [self removeFromParentAndCleanup:YES];
            for (Grid *g in _mySnake.grids) {
                if ([g isEqual:nextGrid]) { [_mySnake bullet:self shootSnakeAt:g]; }
            }
            for (Grid *g in _otherSnake.grids) {
                if ([g isEqual:nextGrid]) { [_mySnake bullet:self shootSnakeAt:g]; }
            }
        }
        
        _map.mapInfo[_positionInGrid.row][_positionInGrid.col] = [NSNumber numberWithInt:EMPTY];
    }
    else {
        // out of bound
        // i.e : crash to wall
        [self removeFromParentAndCleanup:YES];
    }
    
}



@end
