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
    
    int attack;
    int defence;
    int hp;
    
    int redKeyCount;
    int yellowKeyCount;
    int blueKeyCount;
    
    int money;
    int exp;
    int level;
}

@property(retain,nonatomic)CCSprite *sprite;
@property(assign,nonatomic)struct position position;

@property(assign,nonatomic)int attack;
@property(assign,nonatomic)int defence;
@property(assign,nonatomic)int hp;

@property(assign,nonatomic)int redKeyCount;
@property(assign,nonatomic)int yellowKeyCount;
@property(assign,nonatomic)int blueKeyCount;

@property(assign,nonatomic)int money;
@property(assign,nonatomic)int exp;
@property(assign,nonatomic)int level;

-(void)setPositionWithX:(NSInteger)x AndY:(NSInteger)y;
-(int)checkWhoWinWithAttack:(int)attackB Defence:(int)defenceB HP:(int)hpB;
-(NSDictionary*)checkHPWithAttack:(int)attackB Defence:(int)defenceB HP:(int)hpB Time:(int)hitTime;

@end
