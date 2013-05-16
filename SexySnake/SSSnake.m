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

- (void)updateSnakeInfo:(NSMutableArray*) bodyArray
{
    _grids = [NSMutableArray array];
    NSUInteger temp = self.length;
    if (temp < bodyArray.count) {
        for (int i = temp; i < bodyArray.count; ++i)
            [_components addObject:[CCSprite spriteWithFile:@"snake-body.png"]];
    } else if (temp > bodyArray.count) {
        for (int i = bodyArray.count; i < temp; ++i)
            [_components removeLastObject];
    }
    for (NSArray *gridInfo in bodyArray) {
        [_grids addObject:[Grid gridWithRow:[gridInfo[0] intValue] Col:[gridInfo[1] intValue]]];
    }
    [self reorganize];
    
    
    
    
    
    
    [_gameLayer updateScoreLabelForSnake:self];
}

// call this method when add or remove components
- (void)reorganize
{
    [self removeAllChildrenWithCleanup:YES];
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
        //CCLOG(@"[Snake] head now move to %@", newHead);
        if (!_hasEaten) {
            for (int i = _components.count - 1; i > 0; --i) {
                _grids[i] = _grids[i - 1];
//                ((CCSprite *) _components[i]).position = [Grid positionWithGrid:_grids[i]];
                CGPoint p = [Grid positionWithGrid:_grids[i-1]];
                id move = [CCMoveTo actionWithDuration:BASE_UPDATE_INTERVAL position:p];
                move = [CCEaseInOut actionWithAction:move rate:2.0];
                [(CCSprite *)_components[i] runAction:move];
            }
        } else {
            _hasEaten = NO;
        }
                
        _grids[0] = newHead;
        CGPoint p = [Grid positionWithGrid:newHead];
//        ((CCSprite *) _components[0]).position = [Grid positionWithGrid:_grids[0]];
        id move = [CCMoveTo actionWithDuration:BASE_UPDATE_INTERVAL position:p];
//        move = [CCEaseInOut actionWithAction:move rate:2.0];
        [(CCSprite *)_components[0] runAction:move];
        
        if (!_hasEaten && _grids.count > 5) {
            for (NSUInteger i = 4; i < _grids.count; ++i) {
                Grid *head = _grids[0];
                Grid *body = _grids[i];
                if ( (head.row == body.row) && (head.col == body.col) ) {
                    
                    [self getBitAtIndex:i];
                    break;
                }
            }
        }
    
        
        
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
    
    //CCLOG(@"[Snake] eat target at (%d, %d)", grid.row, grid.col);
    
    [_components insertObject:body atIndex:1];
    [_grids insertObject:grid atIndex:1];
    
    [self addChild:body];
    
    _hasEaten = YES;
    [_gameLayer updateScoreLabelForSnake:self];
}

- (void)eatBulletTarget
{
    if (_numberOfBulletTarget < MAX_BULLET_NUM)
        ++self.numberOfBulletTarget;
    [_gameLayer updateShootButton];
    // update UI
    // play sound effect
}

- (void)shoot
{
    --self.numberOfBulletTarget;
    Grid *nextGrid = [Grid gridForDirection:_direction toGrid:_grids[0]];
    BulletSprite *bullet = [BulletSprite bulletWithPositionInGrid:nextGrid andDirection:_direction];
    bullet.delegate = (GameLayer<BulletSpriteDelegate> *)_gameLayer;
    [[self parent] addChild:bullet];
    [bullet fire];
    
    [[SSConnectionManager sharedManager] sendMessage:@"shoot" forAction:ACTION_SHOOT];
    
    [_gameLayer updateShootButton];
}

//- (void)finishShooting
//{
//    _isShoot = NO;
//}

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
    //CCLOG(@"[Snake] hit wall at %@", _grids[0]);
    if (self.length > 1) {
        [self removeChild:[_components lastObject] cleanup:NO];
        [_components removeLastObject];
        [_grids removeLastObject];
    }
    _hasLongBia = YES;
    [_gameLayer updateScoreLabelForSnake:self];
}

- (void)getShotAt:(Grid*)grid
{
    NSUInteger hurtIndex = [_grids indexOfObject:grid];
    //CCLOG(@"[Snake] It's hurt at %d", hurtIndex);
    if (hurtIndex > 0) {
        // not hurt at head
        for (NSUInteger i = hurtIndex; i < self.length; ++i) {
            [self removeChild:[_components lastObject] cleanup:NO];
            [_components removeLastObject];
            [_grids removeLastObject];
        }
    }
    [_gameLayer updateScoreLabelForSnake:self];
}

- (void)bullet:(BulletSprite *)bullet shootSnakeAt:(Grid *)grid
{
//    NSLog(@"hit snake!!!");
    
//    CCSprite *lightRing = [CCSprite spriteWithFile:@"destroyedeffect.png"];
//    lightRing.position = [Grid positionWithGrid:grid];
//    [_gameLayer addChild:lightRing];
//    
//    id callback = [CCCallFuncND actionWithTarget:_gameLayer selector:@selector(removeChild:cleanup:) data:YES];
//    id scaleAction = [CCScaleTo actionWithDuration:0.3 scale:3];
//    id easeScaleAction = [CCEaseInOut actionWithAction:scaleAction rate:2];
//    CCSequence *sequence = [CCSequence actions:easeScaleAction, callback, nil];
//    [lightRing runAction:sequence];
//    
    [self getShotAt:grid];
}

- (void)getBitAt:(Grid *)grid
{
    for (NSUInteger i = 1; i < _grids.count; ++i) {
        if (grid.row == ((Grid *) _grids[i]).row && grid.col == ((Grid *) _grids[i]).col) {
            [self getBitAtIndex:i];
            break;
        }
    }
}

- (void)getBitAtIndex:(NSUInteger)index
{
    for (NSUInteger i = _grids.count - 1; i > index; --i) {
        [_gameLayer.map wallIsBuiltAt:_grids[i]];
        [_grids removeLastObject];
        CCSprite *last = _components[i];
        [last removeFromParentAndCleanup:YES];
        [_components removeLastObject];
    }
}

@end


