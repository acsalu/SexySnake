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
       Grid *pos = [sSnake objectAtIndex:i];
       if (_mapInfo[pos.row][pos.col] == [NSNumber numberWithInt:BULLET]){
           
           //TODO:Notifying snake
           
           break;
       }
   }
    
   for(int i=0; i<[cSnake count]; i++){
       Grid *pos = [cSnake objectAtIndex:i];
       if(_mapInfo[pos.row][pos.col] == [NSNumber numberWithInt:BULLET]){
           
           //TODO:Notifying snake
           
           break;
       }
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
    bullet.position = ccp(_startX + MAX_COLS * GRID_SIZE, _startY - MAX_ROWS * GRID_SIZE);
    [_gameLayer addChild:bullet];

}


@end

@implementation Grid



+ (CGPoint)positionWithGrid:(Grid *)grid
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    CGFloat startX = 20;
    CGFloat startY = size.height - 80;
    CGPoint p = ccp(startX + grid.col * GRID_SIZE, startY - grid.row * GRID_SIZE);
    
    return p;
}

+ (Grid*)gridWithRow:(int)r Col:(int)c;
{
    Grid *grid = [[Grid alloc] init];
    grid.row = r;
    grid.col = c;
    return grid;
}

+ (Grid*)gridForDirection:(Direction)direction toGrid:(Grid *)grid
{
    switch (direction) {
        case UP:
            return [Grid gridWithRow:grid.row - 1 Col:grid.col];
        case DOWN:
            return [Grid gridWithRow:grid.row + 1 Col:grid.col];
        case RIGHT:
            return [Grid gridWithRow:grid.row Col:grid.col + 1];
        case LEFT:
            return [Grid gridWithRow:grid.row Col:grid.col - 1];
    }
}

@end