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
#import "Const.h"
#import "GameLayer.h"
#import "BulletSprite.h"

@implementation SSSnake

+ (SSSnake *)mySnakeWithInitialGrid:(Grid *)grid
{
    SSSnake *snake = [SSSnake node];
    
    // set initial motion properties
    
    // create head
    snake.components = [NSMutableArray arrayWithCapacity:1];
    
    if ([SSConnectionManager sharedManager].role == SERVER)
        snake.components[0] = [CCSprite spriteWithFile:@"snake-head-green.png"];
    else
        snake.components[0] = [CCSprite spriteWithFile:@"snake-head-blue.png"];
    
    snake.grids = [NSMutableArray arrayWithCapacity:1];
    snake.grids[0] = grid;
    
    [snake reorganize];
    
    return snake;
}

+ (SSSnake *)otherSnakeWithInitialGrid:(Grid *)grid
{
    SSSnake *snake = [SSSnake node];
    
    // set initial motion properties
    
    // create head
    snake.components = [NSMutableArray arrayWithCapacity:1];
    
    if ([SSConnectionManager sharedManager].role == SERVER)
        snake.components[0] = [CCSprite spriteWithFile:@"snake-head-blue.png"];
    else
        snake.components[0] = [CCSprite spriteWithFile:@"snake-head-green.png"];
    
    snake.grids = [NSMutableArray arrayWithCapacity:1];
    snake.grids[0] = grid;
    snake.direction = UP;
    
    [snake reorganize];
    
    return snake;
}

#pragma mark - Properties
- (NSUInteger) length
{
    return _components.count;
}


#pragma mark - Snake Body Changing

- (void)setDirection:(Direction)direction
{
    if (direction == [Const reverseForDirection:_direction]) return;
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

- (void)setNumberOfBulletTarget:(int)numberOfBulletTarget
{
    _numberOfBulletTarget = numberOfBulletTarget;
    [_gameLayer updateShootButton];
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
    if (_hasLongBia) {
        _hasLongBia = NO;
        return;
    }
    if (newHead) {
        CCLOG(@"[Snake] head now move to %@", newHead);
        if (!_hasEaten) {
            for (int i = _components.count - 1; i > 0; --i) {
                _grids[i] = _grids[i - 1];
                ((CCSprite *) _components[i]).position = [Grid positionWithGrid:_grids[i]];
            }
        } else {
            _hasEaten = NO;
        }
                
        _grids[0] = newHead;
        ((CCSprite *) _components[0]).position = [Grid positionWithGrid:_grids[0]];
    }
}

#pragma mark - Snake Actions

- (void)move
{
    [self reformWithNewHeadGrid:[Grid gridForDirection:_direction toGrid:_grids[0]]];
}

- (void)eatTarget
{
    CCSprite *body = [CCSprite spriteWithFile:@"snake-body.png"];
    Grid *grid = [Grid gridWithRow:((Grid *) _grids[0]).row Col:((Grid *) _grids[0]).col];
    
    CCLOG(@"[Snake] eat target at (%d, %d)", grid.row, grid.col);
    
    [_components insertObject:body atIndex:1];
    [_grids insertObject:grid atIndex:1];
    
    [self addChild:body];
    
    _hasEaten = YES;
}

- (void)eatBulletTarget
{
    if (_numberOfBulletTarget < MAX_BULLET_NUM)
        ++self.numberOfBulletTarget;
    // update UI
    // play sound effect
}

- (void)shoot
{
    if (self.numberOfBulletTarget > 0) {
        --self.numberOfBulletTarget;
        Grid *nextGrid = [Grid gridForDirection:_direction toGrid:_grids[0]];
        BulletSprite *bullet = [BulletSprite bulletWithPositionInGrid:nextGrid andDirection:_direction];
        bullet.delegate = (GameLayer<BulletSpriteDelegate> *)_gameLayer;
        [[self parent] addChild:bullet];
        [bullet fire];
    }
}

- (void)finishShooting
{
    _isShoot = NO;
}

- (void)buildWall
{
    //After pressing building-wall button
    _isBuilding = YES;
}

- (void)finishBuilding
{
    _isBuilding = NO;
}

- (void)hitWall
{
    CCLOG(@"[Snake] hit wall at %@", _grids[0]);
    if (self.length > 1) {
        [self removeChild:[_components lastObject] cleanup:NO];
        [_components removeLastObject];
        [_grids removeLastObject];
    }
    _hasLongBia = YES;
}

- (void)getShotAt:(Grid*)grid
{
    NSUInteger hurtIndex = [_grids indexOfObject:grid];
    CCLOG(@"[Snake] It's hurt at %d", hurtIndex);
    if (hurtIndex > 0) {
        // not hurt at head
        for (NSUInteger i = hurtIndex; i < self.length; ++i) {
            [self removeChild:[_components lastObject] cleanup:NO];
            [_components removeLastObject];
            [_grids removeLastObject];
        }
    }
}

@end


