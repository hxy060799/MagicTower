//
//  Player.m
//  MagicTower
//
//  Created by Bill on 12-10-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize sprite;
@synthesize position;
@synthesize gong;
@synthesize fang;
@synthesize hp;

-(id)init{
    if(self=[super init]){
        self.sprite=[[CCSprite alloc]initWithSpriteFrameName:@"player_down.png"];
        self.sprite.anchorPoint=ccp(0,0);
        self.gong=10;
        self.fang=10;
        self.hp=1000;
    }
    return self;
}

-(void)setPositionWithX:(NSInteger)x AndY:(NSInteger)y{
    position.x=x;
    position.y=y;
    
    self.sprite.position=ccp(103+25*x,23+25*y);
}

-(void)dealloc{
    [self.sprite release];
    [super dealloc];
}

@end
