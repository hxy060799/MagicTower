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

-(id)init{
    if(self=[super init]){
        self.sprite=[[CCSprite alloc]initWithSpriteFrameName:@"player_down.png"];
    }
    return self;
}

-(void)dealloc{
    [self.sprite release];
    [super dealloc];
}

@end
