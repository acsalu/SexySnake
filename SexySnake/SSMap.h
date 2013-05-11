//
//  SSMap.h
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Const.h"

@interface SSMap : NSObject

@property (nonatomic) NSMutableDictionary *mapData;

- (void)printMap;
- (void)checkEventOfBiting;
- (void)checkEventOfShooting;
- (void)checkEventOfBuildingWall;
- (void)checkEventOfEatingTarget;
- (void)spawnGeneralTarget;
- (void)spawnBulletTarget;

@end
