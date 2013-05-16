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
//        _bullets = [[NSMutableArray alloc] init];
        _bulletTargets = [[NSMutableArray alloc] init];
//        _bulletDirection = [[NSMutableArray alloc] init];
//        _gridsOfNextFrame = [[NSMutableArray alloc] init];
        _walls = [[NSMutableArray alloc] init];
    }
    return  self;
    //NSLog(@"Finish init");
    
    
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
    if([cSnake containsObject:[sSnake objectAtIndex:0]]){
        //client snake is bit
        [_gameLayer.otherSnake getBitAt:[sSnake objectAtIndex:0]];
    }
    
   if([sSnake containsObject:[cSnake objectAtIndex:0]]){
       //server snake is biten
       [_gameLayer.mySnake getBitAt:[cSnake objectAtIndex:0]];
   }

   Grid *sHead = [sSnake objectAtIndex:0];
   Direction direction = _gameLayer.mySnake.direction;
   Grid *nextGrid = [Grid gridForDirection:direction toGrid:sHead];
   if([_mapInfo[sHead.row][sHead.col] integerValue] == TARGET){
       //NSLog(@"mySnake eats a target");
       [_gameLayer.mySnake eatTarget];
       [self removeTargetAt:sHead];
       [[SimpleAudioEngine sharedEngine] playEffect:@"tritone.mp3" pitch:1.0f pan:1.0f gain:1.0f];
    }
   else if([_mapInfo[nextGrid.row][nextGrid.col] integerValue] == WALL || [_mapInfo[nextGrid.row][nextGrid.col] integerValue] == BOUND){
       [_gameLayer.mySnake hitWall];
   }
   else if([_mapInfo[sHead.row][sHead.col] integerValue] == BULLETTARGET)
   {
       [_gameLayer.mySnake eatBulletTarget];
       [self removeBulletTargetAt:sHead];
       [[SimpleAudioEngine sharedEngine] playEffect:@"tritone.mp3"];
   }

    
    if (_gameLayer.mode == MULTI_PLAYER) {
        Grid *cHead = [cSnake objectAtIndex:0];
        direction = _gameLayer.otherSnake.direction;
        nextGrid = [Grid gridForDirection:direction toGrid:cHead];
        if([_mapInfo[nextGrid.row][nextGrid.col] integerValue] == TARGET){
//            NSLog(@"otherSnake eats a target at (%@)", nextGrid);
           [_gameLayer.otherSnake eatTarget];
           [self removeTargetAt:nextGrid];
           [[SimpleAudioEngine sharedEngine] playEffect:@"tritone.mp3"];
     
        }
        else if([_mapInfo[nextGrid.row][nextGrid.col] integerValue] == WALL || [_mapInfo[nextGrid.row][nextGrid.col] integerValue] == BOUND){
           [_gameLayer.otherSnake hitWall];
        }
        else if([_mapInfo[nextGrid.row][nextGrid.col] integerValue] == BULLETTARGET){
           [_gameLayer.otherSnake eatBulletTarget];
           [self removeBulletTargetAt:nextGrid];
           [[SimpleAudioEngine sharedEngine] playEffect:@"tritone.mp3"];
        }

//        for(int i=0; i<[sSnake count]; i++){
//           Grid *pos = [sSnake objectAtIndex:i];
//           if ([_mapInfo[pos.row][pos.col] integerValue] == BULLET){
//               [_gameLayer.mySnake getShotAt:pos];
//               [self removeBulletAt:pos];
//               break;
//           }
//        }

//        for(int i=0; i<[cSnake count]; i++){
//           Grid *pos = [cSnake objectAtIndex:i];
//           if([_mapInfo[pos.row][pos.col] integerValue] == BULLET){
//               [_gameLayer.otherSnake getShotAt:pos];
//               [self removeBulletAt:pos];
//               break;
//           }
//        }
    }

}

//- (void)snakeShootsAt:(Grid *)grid WithDireciton:(Direction)direction
//{
//    _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:BULLET];
//    CCSprite *bullet = [CCSprite spriteWithFile:@"bullet.png"];
//    [_bullets addObject:bullet];
//    bullet.position = [Grid positionWithGrid:grid];
//    [_gameLayer addChild:bullet];
//    [_bulletDirection addObject:[NSNumber numberWithInt:direction]];
//
//    
//}

//Generate a new general target
- (void)spawnTarget
{
    if ([_targets count] < 3) {
        
        int row, col;
        
        while (true) {
            row = arc4random() % MAX_ROWS;
            col = arc4random() % MAX_COLS;
            //NSLog(@"r:%i, c:%i",row,col);
            //NSLog(@"%@",_mapInfo[row][col]);
            //BOOL isOccupied = NO;
            //NSLog(@"%d",EMPTY);
            if ([_mapInfo[row][col] isEqual: [NSNumber numberWithInt:EMPTY]]){

                //isOccupied = YES;
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
    if ([_bulletTargets count] < 3) {
        
        int row, col;
        
        while (true) {
            row = arc4random() % MAX_ROWS;
            col = arc4random() % MAX_COLS;
            //BOOL isOccupied = NO;
            if ([_mapInfo[row][col] isEqual:[NSNumber numberWithInt:EMPTY] ]){
                //isOccupied = YES;
                _mapInfo[row][col] = [NSNumber numberWithInt:BULLETTARGET];
                break;
            }
        }
        
        CCSprite *bulletTarget = [CCSprite spriteWithFile:@"bullet_target.png"];
        [_bulletTargets addObject:bulletTarget];
        Grid *grid = [Grid gridWithRow:row Col:col];
        bulletTarget.position = [Grid positionWithGrid:grid];
        [_gameLayer addChild:bulletTarget];
    }
    
    [self performSelector:@selector(spawnBulletTarget) withObject:nil afterDelay:3];

}

- (void)removeTargetAt:(Grid *)grid
{
    for(int i=0; i<[_targets count]; i++){
        CCSprite *target = [_targets objectAtIndex:i];
        if (CGPointEqualToPoint(target.position,[Grid positionWithGrid:grid])) {
            [_targets removeObjectAtIndex:i];
            [_gameLayer removeChild:target cleanup:YES];
            _mapInfo[grid.row][grid.col] = @(EMPTY);
            
//            CCSprite *lightRing = [CCSprite spriteWithFile:@"destroyedeffect.png"];
//            lightRing.position = [Grid positionWithGrid:grid];
//            [_gameLayer addChild:lightRing];
//            
//            id callback = [CCCallFuncND actionWithTarget:_gameLayer selector:@selector(removeChild:cleanup:) data:YES];
//            id scaleAction = [CCScaleTo actionWithDuration:0.3 scale:3];
//            id easeScaleAction = [CCEaseInOut actionWithAction:scaleAction rate:2];
//            CCSequence *sequence = [CCSequence actions:easeScaleAction, callback, nil];
//            [lightRing runAction:sequence];
        }
    }
    
    _mapInfo[grid.row][grid.col] = @(EMPTY);
}

- (void)removeBulletTargetAt:(Grid *)grid
{
    for (int i=0; i<[_bulletTargets count]; i++) {
        CCSprite *bulletTarget = [_bulletTargets objectAtIndex:i];
        if(CGPointEqualToPoint(bulletTarget.position, [Grid positionWithGrid:grid])){
            [_bulletTargets removeObjectAtIndex:i];
            [_gameLayer removeChild:bulletTarget cleanup:YES];
            _mapInfo[grid.row][grid.col] = @(EMPTY);
            
//            CCSprite *lightRing = [CCSprite spriteWithFile:@"destroyedeffect.png"];
//            lightRing.position = [Grid positionWithGrid:grid];
//            [_gameLayer addChild:lightRing];
//            
//            id callback = [CCCallFuncND actionWithTarget:_gameLayer selector:@selector(removeChild:cleanup:) data:YES];
//            id scaleAction = [CCScaleTo actionWithDuration:0.3 scale:3];
//            id easeScaleAction = [CCEaseInOut actionWithAction:scaleAction rate:2];
//            CCSequence *sequence = [CCSequence actions:easeScaleAction, callback, nil];
//            [lightRing runAction:sequence];
        }
    }
    _mapInfo[grid.row][grid.col] = @(EMPTY);
}


//- (void)removeBulletAt:(Grid *)grid
//{
//    for (int i=0; i<[_bullets count]; i++) {
//        CCSprite *bullet = [_bullets objectAtIndex:i];
//        if(CGPointEqualToPoint(bullet.position, [Grid positionWithGrid:grid])){
//            [_bullets removeObjectAtIndex:i];
//            [_bulletDirection removeObjectAtIndex:i];
//            [_gridsOfNextFrame removeObjectAtIndex:i];
//            [_gameLayer removeChild:bullet cleanup:YES];
//        }
//    }
//}

- (void)removeWallAt:(Grid *)grid
{
    for (int i=0; i<[_walls count]; i++) {
        CCSprite *wall = [_walls objectAtIndex:i];
        if (CGPointEqualToPoint(wall.position, [Grid positionWithGrid:grid])) {
            [_walls removeObjectAtIndex:i];
            [_gameLayer removeChild:wall cleanup:YES];
            _mapInfo[grid.row][grid.col] = @(EMPTY);
            
//            CCSprite *lightRing = [CCSprite spriteWithFile:@"destroyedeffect.png"];
//            lightRing.position = [Grid positionWithGrid:grid];
//            [_gameLayer addChild:lightRing];
//            
//            id callback = [CCCallFuncND actionWithTarget:_gameLayer selector:@selector(removeChild:cleanup:) data:YES];
//            id scaleAction = [CCScaleTo actionWithDuration:0.3 scale:3];
//            id easeScaleAction = [CCEaseInOut actionWithAction:scaleAction rate:2];
//            CCSequence *sequence = [CCSequence actions:easeScaleAction, callback, nil];
//            [lightRing runAction:sequence];
        }
    }
}

//- (void)updatePositionOfBullet
//{
//    if ([_bullets count] > 0) {
//        
//        for (int i=0; i<[_bullets count]; i++) {
//            Grid *grid = [_gridsOfNextFrame objectAtIndex:i];
//            Direction d = [_bulletDirection objectAtIndex:i];
//            Grid *nextGrid = [Grid gridForDirection:d toGrid:grid];
//            
//            if (nextGrid != nil) {
//                id movement = [CCMoveTo actionWithDuration:BULLET_INTERVAL position:[Grid positionWithGrid:grid]];
//                [[_bullets objectAtIndex:i] runAction:movement];
//                _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:EMPTY];
//                _mapInfo[nextGrid.row][nextGrid.col] = [NSNumber numberWithInt:BULLET];
//                [_gridsOfNextFrame replaceObjectAtIndex:i withObject:nextGrid];
//            }
//            else{
//                [_gameLayer removeChild:[_bullets objectAtIndex:i] cleanup:YES];
//                [_gridsOfNextFrame removeObjectAtIndex:i];
//                [_bulletDirection removeObjectAtIndex:i];
//                [_bullets removeObjectAtIndex:i];
//                _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:EMPTY];
//            }
//            
//            
//        }
//    }
//    
//}

- (void)wallIsBuiltAt:(Grid *)grid
{
    _mapInfo[grid.row][grid.col] = [NSNumber numberWithInt:WALL];
    CCSprite *wall = [CCSprite spriteWithFile:@"wall.png"];
    wall.position = [Grid positionWithGrid:grid];
    [_gameLayer addChild:wall];
    [_walls addObject:wall];
}

- (NSArray*)mapToArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<MAX_ROWS; i++) {
        for (int j=0; j<MAX_COLS; j++) {
            //[array addObject:_mapInfo[i][j]];
            if ([_mapInfo[i][j] integerValue] != EMPTY) {
                NSMutableArray *temp = [NSMutableArray arrayWithCapacity:3];
                temp[0] = @(i);
                temp[1] = @(j);
                temp[2] = _mapInfo[i][j];
                [array addObject:temp];
            }
        }
    }
//    if ([array count] >0) {
//        NSLog(@"Ouput Array:%@",array);
//    }
    return array;
}

+ (NSMutableArray*)arrayToMap:(NSArray *)array
{
    NSMutableArray *mapArray = [NSMutableArray arrayWithCapacity:MAX_ROWS];
    
    for (int i = 0; i < MAX_ROWS; ++i) {
        mapArray[i] = [NSMutableArray arrayWithCapacity:MAX_COLS];
        for (int j = 0; j < MAX_COLS; ++j) {
            mapArray[i][j] = [array objectAtIndex:i*MAX_COLS+j];
        }
    }
    
    return mapArray;
}

- (void)oneDimensionArrayForMap:(NSMutableArray *)arrayForMap
{
    for (int i=0; i<[_targets count]; i++) {
        [_gameLayer removeChild:[_targets objectAtIndex:i] cleanup:YES];
    }
    [_targets removeAllObjects];
    
    for (int i=0; i<[_bulletTargets count]; i++) {
        [_gameLayer removeChild:[_bulletTargets objectAtIndex:i] cleanup:YES];
    }
    [_bulletTargets removeAllObjects];
    
    for (int i=0; i<[_walls count]; i++) {
        [_gameLayer removeChild:[_walls objectAtIndex:i] cleanup:YES];
    }
    [_walls removeAllObjects];
    
//    if ([arrayForMap count] > 0) {
//        NSLog(@"Received Map:%@",arrayForMap);
//    }
    
    for (int i=0; i<[arrayForMap count]; i++){
        NSMutableArray *array = [arrayForMap objectAtIndex:i];
//        NSLog(@"array:%@",array);
        if ([array[2] integerValue] == TARGET) {
            CCSprite *target = [CCSprite spriteWithFile:@"target.png"];
            [_targets addObject:target];
            target.position = [Grid positionWithGrid:[Grid gridWithRow:[array[0] intValue] Col:[array[1] intValue]]];
            [_gameLayer addChild:target];
        }else if([array[2] integerValue] == BULLETTARGET){
            CCSprite *bulletTarget = [CCSprite spriteWithFile:@"bullet_target.png"];
            [_bulletTargets addObject:bulletTarget];
            bulletTarget.position = [Grid positionWithGrid:[Grid gridWithRow:[array[0] intValue] Col:[array[1]intValue]]];
            [_gameLayer addChild:bulletTarget];
        }else if([array[2] integerValue] == WALL){
            CCSprite *wall = [CCSprite spriteWithFile:@"wall.png"];
            [_walls addObject:wall];
            wall.position = [Grid positionWithGrid:[Grid gridWithRow:[array[0] intValue] Col:[array[1] intValue]]];
            [_gameLayer addChild:wall];
        }
    }
}

- (void)rerenderMap:(NSMutableArray*)arrayForMap
{

    for (int i=0; i<[_targets count]; i++) {
        [_gameLayer removeChild:[_targets objectAtIndex:i] cleanup:YES];
    }
    [_targets removeAllObjects];
    
    for (int i=0; i<[_bulletTargets count]; i++) {
        [_gameLayer removeChild:[_bulletTargets objectAtIndex:i] cleanup:YES];
    }
    [_bulletTargets removeAllObjects];
    
    for (int i=0; i<[_walls count]; i++) {
        [_gameLayer removeChild:[_walls objectAtIndex:i] cleanup:YES];
    }
    [_walls removeAllObjects];
    
    for (int i=0; i<MAX_ROWS; i++) {
        for (int j=0; j<MAX_COLS; j++) {
//            if (_mapInfo[i][j] == [NSNumber numberWithInt:TARGET]) {
//                [self removeTargetAt:[Grid gridWithRow:i Col:j]];
//            }else if(_mapInfo[i][j] == [NSNumber numberWithInt:BULLETTARGET]){
//                [self removeBulletTargetAt:[Grid gridWithRow:i Col:j]];
//            }else if(_mapInfo[i][j] == [NSNumber numberWithInt:WALL]){
//                [self removeWallAt:[Grid gridWithRow:i Col:j]];
//            }
            
            int object = [arrayForMap[i][j] integerValue];
            if(object == TARGET){
                CCSprite *target = [CCSprite spriteWithFile:@"target.png"];
                [_targets addObject:target];
                target.position = [Grid positionWithGrid:[Grid gridWithRow:i Col:j]];
                [_gameLayer addChild:target];
            }else if(object == BULLETTARGET){
                CCSprite *bullettarget = [CCSprite spriteWithFile:@"bullet_target.png"];
                [_bulletTargets addObject:bullettarget];
                bullettarget.position = [Grid positionWithGrid:[Grid gridWithRow:i Col:j]];
                [_gameLayer addChild:bullettarget];
            }else if(object == WALL){
                CCSprite *wall = [CCSprite spriteWithFile:@"wall.png"];
                [_walls addObject:wall];
                wall.position = [Grid positionWithGrid:[Grid gridWithRow:i Col:j]];
                [_gameLayer addChild:wall];
            }
        }
    }
}

@end

@implementation Grid



+ (CGPoint)positionWithGrid:(Grid *)grid
{
    CGFloat startX = [[Const sharedConst] mapStartingX];
    CGFloat startY = [[Const sharedConst] mapStartingY];
    
    CGFloat x = startX + (2 * grid.col + 1) * GRID_SIZE * 0.5 + GRID_WIDTH;
    CGFloat y = startY - (2 * grid.row + 1) * GRID_SIZE * 0.5 - GRID_WIDTH;
    
    CGPoint p = ccp(x, y);
    
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%d, %d)", _row, _col];
}

+ (NSArray*)arrayForGrids:(NSArray *)gridArray
{
    NSInteger length = [gridArray count];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:length];
    
    for (int i=0; i<length; i++) {
        array[i] = [NSMutableArray arrayWithCapacity:2];
        Grid *grid = gridArray[i];
        array[i][0] = @(grid.row);
        array[i][1] = @(grid.col);
    }
    
    return array;
}
@end