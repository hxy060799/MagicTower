//
//  HitLayer.m
//  MagicTower
//
//  Created by Bill on 12-10-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "HitLayer.h"

@interface HitLayer(){
    CCSprite *monsterSprite;
    CCSprite *humanSprite;
    CCLabelTTF *monsterHPLabel;
    CCLabelTTF *humanHPLabel;
    CCLabelTTF *monsterGongLabel;
    CCLabelTTF *monsterFangLabel;
    CCLabelTTF *humanGongLabel;
    CCLabelTTF *humanFangLabel;
    CCLabelTTF *monsterNameLabel;
}
@end

@implementation HitLayer

@synthesize delegate;

-(id)init{
    if(self=[super init]){
        CCSprite *hitBackground=[CCSprite spriteWithFile:@"hitBackground.png"];
        hitBackground.anchorPoint=ccp(0,0);
        hitBackground.position=ccp(0,0);
        [self addChild:hitBackground z:0];
        
        monsterSprite=[CCSprite spriteWithSpriteFrameName:@"BigBat_0.png"];
        monsterSprite.anchorPoint=ccp(0,0);
        monsterSprite.position=ccp(12.5,55.5);
        [self addChild:monsterSprite z:1];
        
        humanSprite=[CCSprite spriteWithSpriteFrameName:@"BigBat_0.png"];
        humanSprite.anchorPoint=ccp(0,0);
        humanSprite.position=ccp(194.5,55.5);
        [self addChild:humanSprite z:1];
        
        monsterHPLabel=[CCLabelTTF labelWithString:@"生命:1000" fontName:@"Marker Felt" fontSize:10];
        monsterHPLabel.anchorPoint=ccp(0,0);
        monsterHPLabel.position=ccp(48,82);
        [self addChild:monsterHPLabel z:1];
        
        monsterGongLabel=[CCLabelTTF labelWithString:@"攻击:10" fontName:@"Marker Felt" fontSize:10];
        monsterGongLabel.anchorPoint=ccp(0,0);
        monsterGongLabel.position=ccp(48,60);
        [self addChild:monsterGongLabel z:1];
        
        monsterFangLabel=[CCLabelTTF labelWithString:@"防御:10" fontName:@"Marker Felt" fontSize:10];
        monsterFangLabel.anchorPoint=ccp(0,0);
        monsterFangLabel.position=ccp(48,35);
        [self addChild:monsterFangLabel z:1];
        
        humanHPLabel=[CCLabelTTF labelWithString:@"生命:1000" fontName:@"Marker Felt" fontSize:10];
        humanHPLabel.anchorPoint=ccp(1,0);
        humanHPLabel.position=ccp(232-48,82);
        [self addChild:humanHPLabel z:1];
        
        humanGongLabel=[CCLabelTTF labelWithString:@"攻击:10" fontName:@"Marker Felt" fontSize:10];
        humanGongLabel.anchorPoint=ccp(1,0);
        humanGongLabel.position=ccp(232-48,60);
        [self addChild:humanGongLabel z:1];
        
        humanFangLabel=[CCLabelTTF labelWithString:@"防御:10" fontName:@"Marker Felt" fontSize:10];
        humanFangLabel.anchorPoint=ccp(1,0);
        humanFangLabel.position=ccp(232-48,35);
        [self addChild:humanFangLabel z:1];
        
        monsterNameLabel=[CCLabelTTF labelWithString:@"大蝙蝠" fontName:@"Marker Felt" fontSize:15];
        monsterNameLabel.position=ccp(26,15);
        [self addChild:monsterNameLabel];
        
        CCLabelTTF *playerNameLabel=[CCLabelTTF labelWithString:@"玩家" fontName:@"Marker Felt" fontSize:15];
        playerNameLabel.position=ccp(232-24,15);
        [self addChild:playerNameLabel];
    }
    return self;
}

-(void)startHitWithPlayer:(Player*)player MonsterHP:(int)hp Attack:(int)attack Defence:(int)defence HitCount:(int)hitCount MonsterName:(NSString*)monsterName ImageData:(NSDictionary*)imageData{
     CCSpriteFrame *monsterFrame=[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:[imageData objectForKey:@"UsingImage"]];
    [monsterSprite setDisplayFrame:monsterFrame];
    
    CCSpriteFrame *humanFrame=[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"player_down.png"];
    [humanSprite setDisplayFrame:humanFrame];
    
    [humanHPLabel setString:[NSString stringWithFormat:@"生命:%i",player.hp]];
    [humanGongLabel setString:[NSString stringWithFormat:@"攻击:%i",player.attack]];
    [humanFangLabel setString:[NSString stringWithFormat:@"防御:%i",player.defence]];
    
    [monsterHPLabel setString:[NSString stringWithFormat:@"生命:%i",hp]];
    [monsterGongLabel setString:[NSString stringWithFormat:@"攻击:%i",attack]];
    [monsterFangLabel setString:[NSString stringWithFormat:@"防御:%i",defence]];
    
    [monsterNameLabel setString:monsterName];
    
    NSMutableArray *animations=[[[NSMutableArray alloc]init]autorelease];
    
    for(int i=0;i<hitCount+1;i++){
        CCCallBlock *animation;
        NSDictionary *hps=[player checkHPWithAttack:attack Defence:defence HP:hp Time:i];
        int aHP=0;
        int bHP=1;
        aHP=([[hps objectForKey:@"AHP"]intValue]>0)?[[hps objectForKey:@"AHP"]intValue]:0;
        bHP=([[hps objectForKey:@"BHP"]intValue]>0)?[[hps objectForKey:@"BHP"]intValue]:0;
        if(i%2==1){
            animation=[[CCCallBlock alloc]initWithBlock:^(void){
                [monsterHPLabel setString:[NSString stringWithFormat:@"生命:%i",bHP]];
                NSLog(@"玩家攻击了%@！玩家:%i  怪兽:%i",monsterName,aHP,bHP);
            }];
        }else{
            animation=[[CCCallBlock alloc]initWithBlock:^(void){
                [humanHPLabel setString:[NSString stringWithFormat:@"生命:%i",aHP]];
                NSLog(@"%@攻击了玩家！玩家:%i  怪兽:%i",monsterName,aHP,bHP);
            }];
        }
        [animations addObject:animation];
        [animations addObject:[CCDelayTime actionWithDuration:0.2]];
    }
    [animations addObject:[CCCallBlock actionWithBlock:^(void){
        if(delegate)[delegate hitFinishedWithLayer:self];
    }]];
    
    [self runAction:[CCSequence actionsWithArray:animations]];
}

@end
