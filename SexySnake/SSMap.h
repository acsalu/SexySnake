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

@interface SSMap : NSObject

@property (nonatomic) NSMutableDictionary *mapData;
@property (nonatomic) NSMutableArray *mapInfo;
@property (nonatomic) NSMutableSet *targets;
@property (nonatomic) NSMutableSet *bullets;
@property (nonatomic) NSMutableSet *walls;
@property (nonatomic) CGFloat startX;
@property (nonatomic) CGFloat startY;
@property (nonatomic,weak) GameLayer *gameLayer;

- (id)init;
- (void)printMap;
- (void)updatePositionOfServerSnake:(NSMutableArray*) sSnake
                        ClientSnake:(NSMutableArray*) cSnake;
//- (void)updateClientSnake;
//- (void)checkEventOfBiting;
//- (void)checkEventOfShooting;
//- (void)checkEventOfBuildingWall;
//- (void)checkEventOfEatingTarget;
- (void)spawnTarget;
- (void)spawnBullet;

@end

@interface Grid : NSObject

@property (nonatomic) int row;
@property (nonatomic) int col;

- (Grid*) gridWithRow:(int)r Col:(int)c;

@end


