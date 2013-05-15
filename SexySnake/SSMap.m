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
        
        _targets = [[NSMutableArray alloc] init];
        _bullets = [[NSMutableArray alloc] init];
        _bulletTargets = [[NSMutableArray alloc] init];
        _bulletDirection = [[NSMutableArray alloc] init];
        _gridsOfLastFrame = [[NSMutableArray alloc] init];
    }
    return  self;
    NSLog(@"Finish init");
    
}

- (void)printMap
{
    for (int i=0; i<[_mapInfo count]; i++) {
        for (int j=0; i<[_mapInfo[i] count]; j++) {
            NSLog(@"%@",_mapInfo[i]);
        }
    }
}

//Update the positions of SeverSnake/Client
- (void)updatePositionOfServerSnake:(NSMutableArray *)sSnake ClientSnake:(NSMutableArray *)cSnake
{
    NSLog(@"Update snake info");
    NSLog(@"mySnake:%@",sSnake);
    NSLog(@"otherSnake:%@",cSnake);
    if([cSnake containsObject:[sSnake objectAtIndex:0]]){
        //client snake is bit
        [_gameLayer.otherSnake getBitAt:[sSnake objectAtIndex:0]];
    }
    
   if([sSnake containsObject:[cSnake objectAtIndex:0]]){
       //server snake is biten
       [_gameLayer.mySnake getBitAt:[cSnake objectAtIndex:0]];
   }

   Grid *sHead = [sSnake objectAtIndex:0];
   if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:TARGET]){
       NSLog(@"mySnake eats a target");
       [_gameLayer.mySnake eatTarget];
       [self removeTargetAt:sHead];
   }
   else if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:WALL]){
       [_gameLayer.mySnake hitWall];
   }
   else if(_mapInfo[sHead.row][sHead.col] == [NSNumber numberWithInt:BULLETTARGET])
   {
       [_gameLayer.mySnake eatBulletTarget];
       [self removeBulletTargetAt:sHead];
   }

   Grid *cHead = [cSnake objectAtIndex:0];
   if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:TARGET]){
       [_gameLayer.otherSnake eatTarget];
       [self removeTargetAt:cHead];
    
   }
   else if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:WALL]){
       [_gameLayer.otherSnake hitWall];
   }
   else if(_mapInfo[cHead.row][cHead.col] == [NSNumber numberWithInt:BULLETTARGET]){
       [_gameLayer.otherSnake eatBulletTarget];
       [self removeBulletTargetAt:cHead];
   }

   for(int i=0; i<[sSnake count]; i++){
       Grid *pos = [sSnake objectAtIndex:i];
       if (_mapInfo[pos.row][pos.col] == [NSNumber numberWithInt:BULLET]){
           [_gameLayer.mySnake getShotAt:pos];
           [self removeBulletAt:pos];
           break;
       }
   }
    
   for(int i=0; i<[cSnake count]; i++){
       Grid *pos = [cSnake objectAtIndex:i];
       if(_mapInfo[pos.row][pos.col] == [NSNumber numberWithInt:BULLET]){
           [_gameLayer.otherSnake getShotAt:pos];
           [self removeBulletAt:pos];
           break;
       }
   }


}

- (void)snakeShootsAt:(Grid *)grid WithDireciton:(Direction)direction
{
    _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:BULLET];
    CCSprite *bullet = [CCSprite spriteWithFile:@"bullet.png"];
    [_bullets addObject:bullet];
    bullet.position = [Grid positionWithGrid:grid];
    [_gameLayer addChild:bullet];
    [_bulletDirection addObject:[NSNumber numberWithInt:direction]];
    
}

//Generate a new general target
- (void)spawnTarget
{
   NSLog(@"Entering spawnTarget");
    if ([_targets count] < 3) {
        
        int row, col;
        
        while (true) {
            row = arc4random() % MAX_ROWS;
            col = arc4random() % MAX_COLS;
            NSLog(@"r:%i, c:%i",row,col);
            BOOL isOccupied = NO;
            if (_mapInfo[row][col] == [NSNumber numberWithInt:EMPTY]){
                isOccupied = YES;
                _mapInfo[row][col] = [NSNumber numberWithInt:TARGET];
                break;
            }
        }
        
        
        CCSprite *target = [CCSprite spriteWithFile:@"target.png"];
        [_targets addObject:target];
        Grid *grid = [Grid gridWithRow:row Col:col];
        target.position = [Grid positionWithGrid:grid];
        [_gameLayer addChild:target];
    }

   [self performSelector:@selector(spawnTarget) withObject:nil afterDelay:2];
    
}

- (void)spawnBulletTarget
{
    int row, col;
    
    while (true) {
        row = arc4random() % MAX_ROWS;
        col = arc4random() % MAX_COLS;
        //BOOL isOccupied = NO;
        if (_mapInfo[row][col] != [NSNumber numberWithInt:EMPTY]){
            //isOccupied = YES;
            _mapInfo[row][col] = [NSNumber numberWithInt:BULLETTARGET];
            break;
        }
    }
    
    CCSprite *bulletTarget = [CCSprite spriteWithFile:@"bullet_target.png"];
    [_bulletTargets addObject:bulletTarget];
    bulletTarget.position = ccp(_startX + col * GRID_SIZE, _startY - row * GRID_SIZE);
    [_gameLayer addChild:bulletTarget];
    
    int delay = (arc4random() % 2)*5;
    [self performSelector:@selector(spawnBulletTarget:) withObject:nil afterDelay:delay];

}

- (void)removeTargetAt:(Grid *)grid
{
    for(int i=0; i<[_targets count]; i++){
        CCSprite *target = [_targets objectAtIndex:i];
        if (CGPointEqualToPoint(target.position,[Grid positionWithGrid:grid])) {
            [_targets removeObjectAtIndex:i];
            [_gameLayer removeChild:target cleanup:YES];
        }
    }
}

- (void)removeBulletTargetAt:(Grid *)grid
{
    for (int i=0; i<[_bulletTargets count]; i++) {
        CCSprite *bulletTarget = [_bulletTargets objectAtIndex:i];
        if(CGPointEqualToPoint(bulletTarget.position, [Grid positionWithGrid:grid])){
            [_bulletTargets removeObjectAtIndex:i];
            [_gameLayer removeChild:bulletTarget cleanup:YES];
        }
    }
}

- (void)removeBulletAt:(Grid *)grid
{
    for (int i=0; i<[_bullets count]; i++) {
        CCSprite *bullet = [_bullets objectAtIndex:i];
        if(CGPointEqualToPoint(bullet.position, [Grid positionWithGrid:grid])){
            [_bullets removeObjectAtIndex:i];
            [_bulletDirection removeObjectAtIndex:i];
            [_gridsOfLastFrame removeObjectAtIndex:i];
            [_gameLayer removeChild:bullet cleanup:YES];
        }
    }
}

- (void)updatePositionOfBullet
{
    for (int i=0; i<[_bullets count]; i++) {
        Grid *grid = [_gridsOfLastFrame objectAtIndex:i];
        Direction d = [_bulletDirection objectAtIndex:i];
        Grid *nextGrid = [Grid gridForDirection:d toGrid:grid];
        
        if (nextGrid != nil) {
            id movement = [CCMoveTo actionWithDuration:BULLET_INTERVAL position:[Grid positionWithGrid:grid]];
            [[_bullets objectAtIndex:i] runAction:movement];
            _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:EMPTY];
            _mapInfo[nextGrid.row][nextGrid.col] = [NSNumber numberWithInt:BULLET];
            [_gridsOfLastFrame replaceObjectAtIndex:i withObject:nextGrid];
        }
        else{
            [_gameLayer removeChild:[_bullets objectAtIndex:i] cleanup:YES];
            [_gridsOfLastFrame removeObjectAtIndex:i];
            [_bulletDirection removeObjectAtIndex:i];
            [_bullets removeObjectAtIndex:i];
            _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:EMPTY];
        }
        

    }
    
}

- (void)wallIsBuiltAt:(Grid *)grid
{
    _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:WALL];
    CCSprite *wall = [CCSprite spriteWithFile:@"wall.png"];
    wall.position = [Grid positionWithGrid:grid];
    [_gameLayer addChild:wall];
}

@end

@implementation Grid



+ (CGPoint)positionWithGrid:(Grid *)grid
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    CGFloat startX = 80;
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
            if (grid.row == 0) {
                return nil;
            }
            else
               return [Grid gridWithRow:grid.row - 1 Col:grid.col];
        case DOWN:
            if (grid.row == MAX_ROWS - 1) {
                return nil;
            }
            else
               return [Grid gridWithRow:grid.row + 1 Col:grid.col];
        case RIGHT:
            if (grid.col == MAX_COLS - 1) {
                return nil;
            }
            else
               return [Grid gridWithRow:grid.row Col:grid.col + 1];
        case LEFT:
            if (grid.col == 0) {
                return nil;
            }
            else
               return [Grid gridWithRow:grid.row Col:grid.col - 1];
    }
}

@end