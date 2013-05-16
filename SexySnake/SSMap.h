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
#import "BulletSprite.h"
#import "SimpleAudioEngine.h"

@class GameLayer;
@class Grid;

@interface SSMap : NSObject <BulletSpriteDelegate>

//@property (nonatomic) NSMutableDictionary *mapData;
@property (nonatomic) NSMutableArray *mapInfo;
@property (nonatomic) NSMutableArray *targets;
@property (nonatomic) NSMutableArray *bulletTargets;
@property (nonatomic) NSMutableArray *bullets;
@property (nonatomic) NSMutableArray *walls;
@property (nonatomic) CGFloat startX;
@property (nonatomic) CGFloat startY;
@property (nonatomic,weak) GameLayer *gameLayer;
@property (nonatomic) NSMutableArray *bulletDirection;
@property (nonatomic) NSMutableArray *gridsOfNextFrame;


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
- (void)removeWallAt:(Grid*)grid;

- (void)updatePositionOfBullet;
- (void)wallIsBuiltAt:(Grid*)grid;

//Utility
- (NSArray*)mapToArray;
+ (NSMutableArray*)arrayToMap:(NSArray*)array;
- (void)oneDimensionArrayForMap:(NSMutableArray*)arrayForMap;
- (void)rerenderMap:(NSMutableArray*)arrayForMap;

@end

@interface Grid : NSObject

@property (nonatomic) int row;
@property (nonatomic) int col;

+ (CGPoint) positionWithGrid:(Grid*)grid;
+ (Grid*) gridWithRow:(int)r Col:(int)c;
+ (Grid*)gridForDirection:(Direction)direction toGrid:(Grid *)grid;
+ (NSArray*)arrayForGrids:(NSArray*)gridArray;

@end


