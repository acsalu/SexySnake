//
//  BulletSprite.m
//  SexySnake
//
//  Created by LCR on 5/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BulletSprite.h"
#import "SSSnake.h"

@implementation BulletSprite

+ (BulletSprite *)bulletWithPositionInGrid:(Grid *)grid andDirection:(Direction)direction
{
    BulletSprite *bullet = [BulletSprite spriteWithFile:@"bullet.png"];
    bullet.positionInGrid = grid;
    bullet.position = [Grid positionWithGrid:grid];
    bullet.rotation = (direction - 1) * 90;
    bullet.direction = direction;
    
    return bullet;
    
}

- (void)fireAtRate:(ccTime)rate
{
//    [self schedule:@selector(updatePosition) interval:1/rate];
    _rate = rate;
    [self updatePosition];

}

- (void)updatePosition
{
    Grid *nextGrid = [Grid gridForDirection:_direction toGrid:_positionInGrid];

    if (nextGrid != nil) {

        Item itemInNextGrid =  [_delegate.map.mapInfo[nextGrid.row][nextGrid.col] intValue];

        if (itemInNextGrid == EMPTY) {
            id movement = [CCMoveTo actionWithDuration:0.01 position:[Grid positionWithGrid:nextGrid]];
            id callback = [CCCallFunc actionWithTarget:self selector:@selector(updatePosition)];
            CCSequence *sequence = [CCSequence actions:movement, callback, nil];
            [self runAction:sequence];
            _positionInGrid = nextGrid;
        } else if (itemInNextGrid == TARGET) {
            // kill target
        } else if (itemInNextGrid == BULLET) {
            // kill bullet
        } else if (itemInNextGrid == WALL) {
            // suicide
        } else if (itemInNextGrid == BULLETTARGET) {
            // kill bullet target
        } else { // snake
//            [_delegate.mySnake.grids containsObject:nextGrid];
//            [_delegate.otherSnake.grids containsObject:nextGrid];

        }
        
        _delegate.map.mapInfo[_positionInGrid.row][_positionInGrid.col] = [NSNumber numberWithInt:EMPTY];
    }
    else {
        // out of bound
        // i.e : crash to wall
        NSLog(@"qq");
    }
    
}


@end
