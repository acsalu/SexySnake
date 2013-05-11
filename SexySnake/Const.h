//
//  SSUtility.h
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//
//

#import <Foundation/Foundation.h>

enum Direction {
    UP = 0, RIGHT, DOWN, LEFT
};

enum Item {
    SNAKE_HEAD = 0, SNAKE_BODY, TARGET
};

typedef enum Direction Direction;
typedef enum Item Item;

#define MAX_COLS 10
#define MAX_ROWS 13
#define GRID_SIZE 30


@interface SSUtility : NSObject

@end
