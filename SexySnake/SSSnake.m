//
//  SSSnake.m
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SSSnake.h"


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
    
    _direction = direction;
}

- (void)reorganize
{
    [self removeAllChildrenWithCleanup:NO];
    for (CCSprite *sprite in _components) {
        [self addChild:sprite];
    }
}

#pragma mark - Snake Actions





@end
