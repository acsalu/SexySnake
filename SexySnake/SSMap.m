//
//  SSMap.m
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//
//

#import "SSMap.h"
#import "GameLayer.h"
#import "SSSnake.h"

@implementation SSMap

- (id)init
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    _startX = 20;
    _startY = size.height - 80;
    _mapInfo = [NSMutableArray arrayWithCapacity:MAX_ROWS];
    
    for (int i = 0; i < MAX_ROWS; ++i) {
        _mapInfo[i] = [NSMutableArray arrayWithCapacity:MAX_COLS];
        for (int j = 0; j < MAX_COLS; ++j) {
            _mapInfo[i][j] = [NSNumber numberWithInt:EMPTY];
        }
    }
    
}

//Update the positions of SeverSnake/Client
- (void)updatePositionOfServerSnake:(NSMutableArray *)sSnake ClientSnake:(NSMutableArray *)cSnake
{
    if([cSnake containsObject:[sSnake objectAtIndex:0]]){
        
    }
    
   if([sSnake containsObject:[cSnake objectAtIndex:0]]){
    
   }

   Grid *sHead = [sSnake objectAtIndex:0];
   if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:TARGET]){
     
   }
   else if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:WALL]){
    
   }

   Grid *cHead = [cSnake objectAtIndex:0];
   if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:TARGET]){
    
   }
   else if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:WALL]){
    
   }

   for(int i=0; i<[sSnake count]; i++){
      
   }


}

//Generate a new general target
- (void)spawnTarget
{
    int row, col;
    
    while (true) {
        row = arc4random() % MAX_ROWS;
        col = arc4random() % MAX_COLS;
        BOOL isOccupied = NO;
        if (_mapInfo[row][col] != [NSNumber numberWithInt:EMPTY]){
            isOccupied = YES;
            _mapInfo[row][col] = [NSNumber numberWithInt:TARGET];
            break;
        }
    }
    
    CCSprite *target = [CCSprite spriteWithFile:@"target.png"];
    [_targets addObject:target];
    target.position = ccp(_startX + MAX_ROWS * GRID_SIZE, _startY + MAX_COLS * GRID_SIZE);
    [_gameLayer addChild:target];
    
}

- (void)spawnBullet
{
    int row, col;
    
    while (true) {
        row = arc4random() % MAX_ROWS;
        col = arc4random() % MAX_COLS;
        BOOL isOccupied = NO;
        if (_mapInfo[row][col] != [NSNumber numberWithInt:EMPTY]){
            isOccupied = YES;
            _mapInfo[row][col] = [NSNumber numberWithInt:BULLET];
            break;
        }
    }
    
    CCSprite *bullet = [CCSprite spriteWithFile:@"bullet.png"];
    [_bullets addObject:bullet];
    bullet.position = ccp(_startX + MAX_ROWS * GRID_SIZE, _startY + MAX_COLS * GRID_SIZE);
    [_gameLayer addChild:bullet];

}


@end
