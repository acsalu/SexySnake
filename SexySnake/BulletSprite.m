//
//  BulletSprite.m
//  SexySnake
//
//  Created by LCR on 5/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BulletSprite.h"


@implementation BulletSprite

+ (BulletSprite *)bulletWithPositionInGrid:(Grid *)grid andDirection:(Direction)direction
{
    BulletSprite *bullet = [CCSprite spriteWithFile:@""];
    bullet.positionInGrid = grid;
    bullet.position = [Grid positionWithGrid:grid];
    bullet.rotation = (direction - 1) * 90;
    
    return bullet;
    
}

- (void)fireAtRate:(ccTime)rate
{
    [self schedule:@selector(updatePosition) interval:1/rate];
}

- (void)updatePosition
{
    Grid *nextGrid = [Grid gridForDirection:_direction toGrid:_positionInGrid];
    
    if (nextGrid != nil) {
//        BOOL moveIsOK = [_delegate bullet:self wouldMoveFrom:_positionInGrid To:nextGrid];

//        if (moveIsOK) {

//        }

        Item itemInNextGrid =  _delegate.map.mapInfo[nextGrid.row][nextGrid.col];
        if (itemInNextGrid == SNAKE_HEAD) {
            // let snake die
        } else if (itemInNextGrid == SNAKE_BODY) {
            // reduce snake lenth
        } else if (itemInNextGrid == TARGET) {
            // kill target
        } else if (itemInNextGrid == BULLET) {
            // kill bullet
        } else if (itemInNextGrid == WALL) {
            // suicide
        } else if (itemInNextGrid == BULLETTARGET) {
            // kill bullet target
        } else { // empty
            // OK GO!
            id movement = [CCMoveTo actionWithDuration:BULLET_INTERVAL position:[Grid positionWithGrid:nextGrid]];
            [self runAction:movement];
            _delegate.map.mapInfo[_positionInGrid.row][_positionInGrid.col] = [NSNumber numberWithInt:EMPTY];
            _delegate.map.mapInfo[nextGrid.row][nextGrid.col] = [NSNumber numberWithInt:BULLET];
        }
    }
    else {
        // out of bound
        // i.e : crash to wall
        
//        [_gameLayer removeChild:[_bullets objectAtIndex:i] cleanup:YES];
//        [_gridsOfLastFrame removeObjectAtIndex:i];
//        [_bulletDirection removeObjectAtIndex:i];
//        [_bullets removeObjectAtIndex:i];
//        _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:EMPTY];
    }
    
}


@end
