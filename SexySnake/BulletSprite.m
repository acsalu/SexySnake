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

    if (nextGrid != nil) {

        Item itemInNextGrid =  [_map.mapInfo[nextGrid.row][nextGrid.col] intValue];
        NSLog(@"nextgrid is %u", itemInNextGrid);
        if (itemInNextGrid == EMPTY) {
            
            for (Grid *g in _mySnake.grids) {
                if ((g.row == nextGrid.row) && (g.col == nextGrid.col)) {
                    [self removeFromParentAndCleanup:YES];
                    if ([SSConnectionManager sharedManager].role == SERVER)
                        [_mySnake bullet:self shootSnakeAt:g];
                    return;
                }
            }
            NSLog(@"next grid : %@", nextGrid);
            for (Grid *g in _otherSnake.grids) {
                NSLog(@"snake grid : %@", g);
                if ((g.row == nextGrid.row) && (g.col == nextGrid.col)) {
                    [self removeFromParentAndCleanup:YES];
                    if ([SSConnectionManager sharedManager].role == SERVER)
                        [_otherSnake bullet:self shootSnakeAt:g];
                    return;
                }
            }
            
            
            id movement = [CCMoveTo actionWithDuration:0.03 position:[Grid positionWithGrid:nextGrid]];
            id callback = [CCCallFunc actionWithTarget:self selector:@selector(updatePosition)];
            CCSequence *sequence = [CCSequence actions:movement, callback, nil];
            [self runAction:sequence];
            
            _positionInGrid = nextGrid;
            
        } else if (itemInNextGrid == TARGET) {
            [self removeFromParentAndCleanup:YES];
            // kill target
            if ([SSConnectionManager sharedManager].role == SERVER)
                [_map removeTargetAt:nextGrid];
            
        } else if (itemInNextGrid == BULLET) {
//            [self removeFromParentAndCleanup:YES];
            // kill bullet
        } else if (itemInNextGrid == WALL) {
            [self removeFromParentAndCleanup:YES];
            if ([SSConnectionManager sharedManager].role == SERVER)
                [_map removeWallAt:nextGrid];
            
            // suicide
        } else if (itemInNextGrid == BULLETTARGET) {
            [self removeFromParentAndCleanup:YES];
            if ([SSConnectionManager sharedManager].role == SERVER)
                [_map removeBulletTargetAt:nextGrid];
            // kill bullet target
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
