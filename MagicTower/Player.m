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
        /*
        self.redKeyCount=10;
        self.yellowKeyCount=10;
        self.blueKeyCount=10;
        
        self.money=500;
        self.exp=500;
        self.level=1;
        
        self.attack=10000;
        self.defence=10000;
        self.hp=1000;
         */
        
        self.redKeyCount=0;
        self.yellowKeyCount=0;
        self.blueKeyCount=0;
        
        self.money=0;
        self.exp=0;
        self.level=1;
        
        self.attack=10;
        self.defence=10;
        self.hp=1000;
        
        self.sprite=[[CCSprite alloc]initWithSpriteFrameName:@"player_down.png"];
        self.sprite.anchorPoint=ccp(0,0);
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

-(int)setPlayerInformationWithString:(NSString*)infName Value:(NSString*)value Append:(BOOL)append{
    
    if([value isEqualToString:@"0.3x"]){
        [self setPlayerInformationWithString:infName Value:[NSString stringWithFormat:@"%i",(int)(0.3*[self getPlayerInformationWithString:infName])] Append:YES];
    }
    if([value isEqualToString:@"2x"]){
        [self setPlayerInformationWithString:infName Value:[NSString stringWithFormat:@"%i",(int)(2*[self getPlayerInformationWithString:infName])] Append:NO];
    }
    
    int valueToSet=[value intValue];
    
    if([infName isEqualToString:@"RedKey"]){
        self.redKeyCount=(append)?self.redKeyCount+valueToSet:valueToSet;
        return self.redKeyCount;
    }else if([infName isEqualToString:@"BlueKey"]){
        self.blueKeyCount=(append)?self.blueKeyCount+valueToSet:valueToSet;
        return self.blueKeyCount;
    }else if([infName isEqualToString:@"YellowKey"]){
        self.yellowKeyCount=(append)?self.yellowKeyCount+valueToSet:valueToSet;
        return self.yellowKeyCount;
    }else if([infName isEqualToString:@"Money"]){
        self.money=(append)?self.money+valueToSet:valueToSet;
        return self.money;
    }else if([infName isEqualToString:@"Exp"]){
        self.exp=(append)?self.exp+valueToSet:valueToSet;
        return self.exp;
    }else if([infName isEqualToString:@"Level"]){
        self.level=(append)?self.level+valueToSet:valueToSet;
        self.hp=(append)?self.hp+valueToSet*1000:valueToSet*1000;
        self.attack=(append)?self.attack+valueToSet*10:valueToSet*10;
        self.defence=(append)?self.defence+valueToSet*10:valueToSet*10;
        return self.level;
    }else if([infName isEqualToString:@"Attack"]){
        self.attack=(append)?self.attack+valueToSet:valueToSet;
        return self.attack;
    }else if([infName isEqualToString:@"Defence"]){
        self.defence=(append)?self.defence+valueToSet:valueToSet;
        return self.defence;
    }else if([infName isEqualToString:@"HP"]){
        self.hp=(append)?self.hp+valueToSet:valueToSet;
        return self.hp;
    }else{
        NSLog(@"No match information name!");
        return -1;
    }
}

-(int)getPlayerInformationWithString:(NSString*)infName{
    return [self setPlayerInformationWithString:infName Value:0 Append:YES];
}

-(void)dealloc{
    [self.sprite release];
    [super dealloc];
}

@end
