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
    SNAKE_HEAD = 0, SNAKE_BODY, TARGET, BULLET, WALL, BULLETTARGET, EMPTY
};

enum Role {
    NONE, SERVER, CLIENT
};

enum Mode {
    SINGLE_PLAYER = 0, MULTI_PLAYER
};

typedef enum Direction Direction;
typedef enum Item Item;
typedef enum Role Role;
typedef enum Mode Mode;

#define MAX_COLS 10
#define MAX_ROWS 13
#define GRID_SIZE 30
#define MAX_INTERVAL 3
#define BULLET_INTERVAL 1


@interface SSUtility : NSObject

@end
