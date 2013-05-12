//
//  SSSnake.m
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SSSnake.h"
#import "SSConnectionManager.h"


@implementation SSSnake

+ (SSSnake *)snakeWithInitialPosition:(CGPoint)position
{
    SSSnake *snake = [SSSnake node];
    
    // set initial motion properties
    
    
    
    // create head
    snake.components = [NSMutableArray arrayWithCapacity:1];
    snake.components[0] = [CCSprite spriteWithFile:@"snake-head.png"];
    
    snake.componentPositions = [NSMutableArray arrayWithCapacity:1];
    snake.componentPositions[0] = [NSValue valueWithCGPoint:position];
                              
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
        ((CCSprite *) _components[i]).position = [self positionForComponentAtIndex:i];
        [self addChild:_components[i]];
    }
}

// call this method when moving
- (void)reformWithNewHeadPosition:(CGPoint)position
{
    for (int i = 1; i < _components.count; ++i) {
        _componentPositions[i] = _componentPositions[i - 1];
        ((CCSprite *) _components[i]).position = [self positionForComponentAtIndex:i];
    }
    
    _componentPositions[0] = [NSValue valueWithCGPoint:position];
    ((CCSprite *) _components[0]).position = [self positionForComponentAtIndex:0];
    
}

#pragma mark - Snake Actions

- (void)move
{
    CGPoint currentHead = [self positionForComponentAtIndex:0];
    CGPoint newHead;
    switch (_direction) {
        case UP:
//            CCLOG(@"Move UP.");
            newHead = ccp(currentHead.x, currentHead.y + GRID_SIZE);
            break;
        case DOWN:
//            CCLOG(@"Move DOWN.");
            newHead = ccp(currentHead.x, currentHead.y - GRID_SIZE);
            break;
        case RIGHT:
//            CCLOG(@"Move RIGHT.");
            newHead = ccp(currentHead.x + GRID_SIZE, currentHead.y);
            break;
        case LEFT:
//            CCLOG(@"Move LEFT.");
            newHead = ccp(currentHead.x - GRID_SIZE, currentHead.y);
            break;
    }
    [self reformWithNewHeadPosition:newHead];
}

- (void)eatTarget
{
    
}


#pragma mark - Utility Methods

- (CGPoint)positionForComponentAtIndex:(NSUInteger)i
{
    return [((NSValue *) _componentPositions[i]) CGPointValue];
}


@end
