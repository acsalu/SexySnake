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
#import "SSConnectionManager.h"

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

    CCSprite *lightRing = [CCSprite spriteWithFile:@"destroyedeffect.png"];
    lightRing.position = [Grid positionWithGrid:nextGrid];
    
    id callback = [CCCallFuncND actionWithTarget:_delegate selector:@selector(removeChild:cleanup:) data:YES];
    id scaleAction = [CCScaleTo actionWithDuration:0.3 scale:3];
    id easeScaleAction = [CCEaseInOut actionWithAction:scaleAction rate:2];
    CCSequence *sequence = [CCSequence actions:easeScaleAction, callback, nil];    
    
    if (nextGrid != nil) {

        Item itemInNextGrid =  [_map.mapInfo[nextGrid.row][nextGrid.col] intValue];
//        NSLog(@"nextgrid is %u", itemInNextGrid);
        if (itemInNextGrid == EMPTY) {
            
            for (Grid *g in _mySnake.grids) {
                if ((g.row == nextGrid.row) && (g.col == nextGrid.col)) {
                    [self removeFromParentAndCleanup:YES];
                    if ([SSConnectionManager sharedManager].role == SERVER)
                        [_mySnake bullet:self shootSnakeAt:g];
                        [_delegate addChild:lightRing];
                        [lightRing runAction:sequence];
                    return;
                }
            }
            for (Grid *g in _otherSnake.grids) {
                if ((g.row == nextGrid.row) && (g.col == nextGrid.col)) {
                    [self removeFromParentAndCleanup:YES];
                    if ([SSConnectionManager sharedManager].role == SERVER)
                        [_otherSnake bullet:self shootSnakeAt:g];
                        [_delegate addChild:lightRing];
                        [lightRing runAction:sequence];

                    return;
                }
            }
            
            
            id movement = [CCMoveTo actionWithDuration:0.02 position:[Grid positionWithGrid:nextGrid]];
            id callback = [CCCallFunc actionWithTarget:self selector:@selector(updatePosition)];
            CCSequence *sequence = [CCSequence actions:movement, callback, nil];
            [self runAction:sequence];
            
            _positionInGrid = nextGrid;
            
        } else if (itemInNextGrid == TARGET) {
            [self removeFromParentAndCleanup:YES];
            if ([SSConnectionManager sharedManager].role == SERVER || [SSConnectionManager sharedManager].role == NONE)
                [_delegate addChild:lightRing];
                [lightRing runAction:sequence];
                [_map removeTargetAt:nextGrid];
            
        } else if (itemInNextGrid == WALL) {
            [self removeFromParentAndCleanup:YES];
            if ([SSConnectionManager sharedManager].role == SERVER || [SSConnectionManager sharedManager].role == NONE)
                [_delegate addChild:lightRing];
                [lightRing runAction:sequence];
                [_map removeWallAt:nextGrid];
            
        } else if (itemInNextGrid == BULLETTARGET) {
            [self removeFromParentAndCleanup:YES];
            if ([SSConnectionManager sharedManager].role == SERVER || [SSConnectionManager sharedManager].role == NONE)
                [_delegate addChild:lightRing];
                [lightRing runAction:sequence];
                [_map removeBulletTargetAt:nextGrid];
            
        } else {
            NSLog(@"fuck");

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
