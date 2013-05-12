//
//  SSSnake.m
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SSSnake.h"
#import "SSConnectionManager.h"
#import "SSMap.h"

@implementation SSSnake

+ (SSSnake *)snakeWithInitialGrid:(Grid *)grid
{
    SSSnake *snake = [SSSnake node];
    
    // set initial motion properties
    
    
    
    // create head
    snake.components = [NSMutableArray arrayWithCapacity:1];
    snake.components[0] = [CCSprite spriteWithFile:@"snake-head.png"];
    
    snake.grids = [NSMutableArray arrayWithCapacity:1];
    snake.grids[0] = grid;
    
    [snake reorganize];
    
    return snake;
}

#pragma mark - Snake Body Changing

- (void)setDirection:(Direction)direction
{
    [self rotateWithDirection:direction];
    
    if (direction != _direction)
        [[SSConnectionManager sharedManager] sendMessage:[@(direction) stringValue] forAction:ACTION_CHANGE_DIRECTION];
    
    _direction = direction;
}

- (void)setDirectionFromRemote:(Direction)direction
{
    [self rotateWithDirection:direction];
    _direction = direction;
}

- (void)rotateWithDirection:(Direction)direction
{
    switch (direction) {
        case UP:
            ((CCSprite *) self.components[0]).rotation = 0;
            break;
        case DOWN:
            ((CCSprite *) self.components[0]).rotation = 180;
            break;
        case RIGHT:
            ((CCSprite *) self.components[0]).rotation = 90;
            break;
        case LEFT:
            ((CCSprite *) self.components[0]).rotation = -90;
    }
}

// call this method when add or remove components
- (void)reorganize
{
    [self removeAllChildrenWithCleanup:NO];
    for (int i = 0; i < _components.count; ++i) {
        ((CCSprite *) _components[i]).position = [Grid positionWithGrid:_grids[i]];
        [self addChild:_components[i]];
    }
}

// call this method when moving
- (void)reformWithNewHeadGrid:(Grid *)newHead;
{
    for (int i = 1; i < _components.count; ++i) {
        _grids[i] = _grids[i - 1];
        ((CCSprite *) _components[i]).position = [Grid positionWithGrid:_grids[i]];
    }
    
    _grids[0] = newHead;
    ((CCSprite *) _components[0]).position = [Grid positionWithGrid:_grids[0]];
    
}

#pragma mark - Snake Actions

- (void)move
{
    [self reformWithNewHeadGrid:[Grid gridForDirection:_direction toGrid:_grids[0]]];
}

- (void)eatTarget
{
    
}



@end


