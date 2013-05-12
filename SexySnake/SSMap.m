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
    if ((self = [super init])) {
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
    return  self;
    
}


//Update the positions of SeverSnake/Client
- (void)updatePositionOfServerSnake:(NSMutableArray *)sSnake ClientSnake:(NSMutableArray *)cSnake
{
    if([cSnake containsObject:[sSnake objectAtIndex:0]]){
        //client snake is biten
        
    }
    
   if([sSnake containsObject:[cSnake objectAtIndex:0]]){
       //server snake is biten
   }

   Grid *sHead = [sSnake objectAtIndex:0];
   if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:TARGET]){
       //TODO

       [self removeTargetAt:sHead];
   }
   else if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:WALL]){
       //TODO
       
       [self removeBulletTargetAt:sHead];
   }
   else if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:BULLETTARGET])
   {
       //TODO
       
       [self removeBulletAt:sHead];
   }

   Grid *cHead = [cSnake objectAtIndex:0];
   if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:TARGET]){
       //TODO
       
       [self removeTargetAt:cHead];
    
   }
   else if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:WALL]){
       //TODO
       
       [self removeBulletTargetAt:cHead];
   }
   else if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:BULLETTARGET]){
       //TODO
       
       [self removeBulletAt:cHead];
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

- (void)snakeShootsAt:(Grid *)grid
{
    _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:BULLET];
    CCSprite *bullet = [CCSprite spriteWithFile:@"bullet.png"];
    [_bullets addObject:bullet];
    bullet.position = [Grid positionWithGrid:grid];
    [_gameLayer addChild:bullet];
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
    target.position = ccp(_startX + col * GRID_SIZE, _startY + row * GRID_SIZE);
    [_gameLayer addChild:target];
    
    int delay = arc4random() % 3;
    [self performSelector:@selector(spawnTarget) withObject:nil afterDelay:delay];
    
}

- (void)spawnBulletTarget
{
    int row, col;
    
    while (true) {
        row = arc4random() % MAX_ROWS;
        col = arc4random() % MAX_COLS;
        BOOL isOccupied = NO;
        if (_mapInfo[row][col] != [NSNumber numberWithInt:EMPTY]){
            isOccupied = YES;
            _mapInfo[row][col] = [NSNumber numberWithInt:BULLETTARGET];
            break;
        }
    }
    
    CCSprite *bulletTarget = [CCSprite spriteWithFile:@"bullet_target.png"];
    [_bulletTargets addObject:bulletTarget];
    bulletTarget.position = ccp(_startX + col * GRID_SIZE, _startY - row * GRID_SIZE);
    [_gameLayer addChild:bulletTarget];
    
    int delay = arc4random() % 3;
    [self performSelector:@selector(spawnBulletTarget) withObject:nil afterDelay:delay];

}

- (void)removeTargetAt:(Grid *)grid
{
    for(int i=0; i<[_targets count]; i++){
        CCSprite *target = [_targets objectAtIndex:i];
        if (CGPointEqualToPoint(target.position,[Grid positionWithGrid:grid])) {
            [_targets removeObjectAtIndex:i];
        }
    }
}

- (void)removeBulletTargetAt:(Grid *)grid
{
    for (int i=0; i<[_bulletTargets count]; i++) {
        CCSprite *bulletTarget = [_bulletTargets objectAtIndex:i];
        if(CGPointEqualToPoint(bulletTarget.position, [Grid positionWithGrid:grid])){
            [_bulletTargets removeObjectAtIndex:i];
        }
    }
}

- (void)removeBulletAt:(Grid *)grid
{
    for (int i=0; i<[_bullets count]; i++) {
        CCSprite *bullet = [_bullets objectAtIndex:i];
        if(CGPointEqualToPoint(bullet.position, [Grid positionWithGrid:grid])){
            [_bullets removeObjectAtIndex:i];
        }
    }
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