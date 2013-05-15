//
//  SSMap.h
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Const.h"
#import "cocos2d.h"


@class GameLayer;
@class Grid;

@interface SSMap : NSObject

//@property (nonatomic) NSMutableDictionary *mapData;
@property (nonatomic) NSMutableArray *mapInfo;
@property (nonatomic) NSMutableArray *targets;
@property (nonatomic) NSMutableArray *bulletTargets;
@property (nonatomic) NSMutableArray *bullets;
@property (nonatomic) NSMutableSet *walls;
@property (nonatomic) CGFloat startX;
@property (nonatomic) CGFloat startY;
@property (nonatomic,weak) GameLayer *gameLayer;
@property (nonatomic) NSMutableArray *bulletDirection;
@property (nonatomic) NSMutableArray *gridsOfLastFrame;


- (void)printMap;

//Update snake's motion
- (void)updatePositionOfServerSnake:(NSMutableArray*) sSnake
                        ClientSnake:(NSMutableArray*) cSnake;
- (void)snakeShootsAt:(Grid*) grid
        WithDireciton:(Direction)direction;

//Generate new objects
- (void)spawnTarget;
- (void)spawnBulletTarget;

//Remove objects
- (void)removeTargetAt:(Grid*)grid;
- (void)removeBulletTargetAt:(Grid*)grid;
- (void)removeBulletAt:(Grid*)grid;

- (void)updatePositionOfBullet;
- (void)wallIsBuiltAt:(Grid*)grid;

@end

@interface Grid : NSObject

@property (nonatomic) int row;
@property (nonatomic) int col;

+ (CGPoint) positionWithGrid:(Grid*)grid;
+ (Grid*) gridWithRow:(int)r Col:(int)c;
+ (Grid*)gridForDirection:(Direction)direction toGrid:(Grid *)grid;

@end


