//
//  Player.h
//  MagicTower
//
//  Created by Bill on 12-10-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cocos2d.h"

struct position{
    int x;
    int y;
};

@interface Player : NSObject{
    CCSprite *sprite;
    struct position position;
    
    int gong;
    int fang;
    int hp;
}

@property(retain,nonatomic)CCSprite *sprite;
@property(assign,nonatomic)struct position position;
@property(assign,nonatomic)int gong;
@property(assign,nonatomic)int fang;
@property(assign,nonatomic)int hp;

-(void)setPositionWithX:(NSInteger)x AndY:(NSInteger)y;

@end
