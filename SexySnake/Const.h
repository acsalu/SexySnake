//
//  SSUtility.h
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//
//

#import <Foundation/Foundation.h>

#define REVERSE_DIRECTION(d)  -d

extern NSString * const JSONKeyAction;
extern NSString * const JSONKeyMessage;

enum Direction {
    UP = 1, DOWN = -1,
    RIGHT = 2, LEFT = -2
};

enum Item {
    SNAKE_HEAD = 1000, SNAKE_BODY, TARGET, BULLET, WALL, BULLETTARGET, EMPTY
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

#define MAX_COLS 29
#define MAX_ROWS 18
#define GRID_SIZE 30

#define SERVER_ROW 9
#define SERVER_COL 10
#define CLIENT_ROW 9
#define CLIENT_COL 20

#define MAX_INTERVAL 3
#define BULLET_INTERVAL 1


#define GRID_WIDTH 1

@interface Const : NSObject

+ (Const *)sharedConst;

// upper left corner of the map
@property (nonatomic, assign) CGFloat mapStartingX;
@property (nonatomic, assign) CGFloat mapStartingY;

@end
