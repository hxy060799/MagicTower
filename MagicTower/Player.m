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

@synthesize attack;
@synthesize defence;
@synthesize hp;

@synthesize redKeyCount;
@synthesize yellowKeyCount;
@synthesize blueKeyCount;

@synthesize money;
@synthesize exp;
@synthesize level;

-(id)init{
    if(self=[super init]){
        self.redKeyCount=10;
        self.yellowKeyCount=10;
        self.blueKeyCount=10;
        
        self.money=500;
        self.exp=500;
        self.level=1;
        
        self.sprite=[[CCSprite alloc]initWithSpriteFrameName:@"player_down.png"];
        self.sprite.anchorPoint=ccp(0,0);
        self.attack=10000;
        self.defence=10000;
        self.hp=1000;
    }
    return self;
}

-(void)setPositionWithX:(NSInteger)x AndY:(NSInteger)y{
    position.x=x;
    position.y=y;
    
    self.sprite.position=ccp(103+25*x,23+25*y);
}

-(int)checkWhoWinWithAttack:(int)attackB Defence:(int)defenceB HP:(int)hpB{
    int hurtA=0,hurtB=0;
    hurtA=attackB-self.defence;
    hurtB=self.attack-defenceB;
    int dieTimeA=0,dieTimeB=0;
    if(hurtA<0)hurtA=0;
    if(hurtB<0)hurtB=0;
    NSLog(@"hurtA=%d,hpA=%d hurtB=%d,hpB=%d",hurtA,hp,hurtB,hpB);

    if(hurtA<=0&&hurtB>0){        
        NSLog(@"AWin");
        dieTimeB=(hpB%hurtB>0)?hpB/hurtB+1:hpB/hurtB;
        return 2*dieTimeB-1;
    }else if(hurtA>0&&hurtB<=0){
        NSLog(@"BWin");
        return -1;
    }else if(hurtA<=0&&hurtB<=0){
        NSLog(@"NoOneWin");
        return -1;
    }else{
        dieTimeA=(hp%hurtA>0)?hp/hurtA+1:hp/hurtA;
        dieTimeB=(hpB%hurtB>0)?hpB/hurtB+1:hpB/hurtB;
        
        if(dieTimeA<dieTimeB){
            return -1;
        }else{
            return 2*dieTimeB-1;
        }
    
        NSLog(@"ADieTime%i.BDieTime%i",dieTimeA,dieTimeB);
    }
}

-(NSDictionary*)checkHPWithAttack:(int)attackB Defence:(int)defenceB HP:(int)hpB Time:(int)hitTime{
    int hurtA=0,hurtB=0;
    hurtA=attackB-self.defence;
    hurtB=self.attack-defenceB;
    if(hurtA<0)hurtA=0;
    if(hurtB<0)hurtB=0;
    
    NSMutableDictionary *resultDictionary=[[[NSMutableDictionary alloc]init]autorelease];
    
    if(hitTime%2>0){
        int aNowHp=self.hp-(hitTime-1)/2*hurtA;
        int bNowHp=hpB-((hitTime-1)/2+1)*hurtB;
        [resultDictionary setObject:[NSNumber numberWithInt:aNowHp] forKey:@"AHP"];
        [resultDictionary setObject:[NSNumber numberWithInt:bNowHp] forKey:@"BHP"];
    }else{
        int aNowHp=self.hp-(hitTime/2)*hurtA;
        int bNowHp=hpB-(hitTime/2)*hurtB;
        [resultDictionary setObject:[NSNumber numberWithInt:aNowHp] forKey:@"AHP"];
        [resultDictionary setObject:[NSNumber numberWithInt:bNowHp] forKey:@"BHP"];           
    }
    
    return resultDictionary;
}

-(void)dealloc{
    [self.sprite release];
    [super dealloc];
}

@end
