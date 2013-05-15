//
//  SSUtility.h
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//
//

#import <Foundation/Foundation.h>

#define BASE_UPDATE_INTERVAL 0.3

extern NSString * const JSONKeyAction;
extern NSString * const JSONKeyMessage;

extern NSString * const AmenaFontName;

enum Direction {
    UP = 0, DOWN, RIGHT, LEFT
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

#define MAX_COLS 28
#define MAX_ROWS 21
#define GRID_SIZE 30

#define SERVER_ROW 10
#define SERVER_COL 9
#define CLIENT_ROW 10
#define CLIENT_COL 20

#define MAX_INTERVAL 3
#define BULLET_INTERVAL 1


#define GRID_WIDTH 1

#define MAX_BULLET_NUM 5

@interface Const : NSObject

+ (Const *)sharedConst;
+ (Direction)reverseForDirection:(Direction)direction;

// upper left corner of the map
@property (nonatomic, assign) CGFloat mapStartingX;
@property (nonatomic, assign) CGFloat mapStartingY;

@end
