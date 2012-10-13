//
//  GameLayer.m
//  MagicTower
//
//  Created by Bill on 12-10-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"

@interface GameLayer(){
    //玩家当前位于的楼层.注意:第一层对应的索引为1,因为前面还有个序章
    NSInteger currentFloor;
    //游戏地图，三位数组[楼层,x,y](x<11,y<11)
    NSMutableArray *gameMap;
    //地图是通过11*11=121个精灵拼凑而成的,这是个二维数组
    NSMutableArray *mapSprites;
    //将要被移重新加载的地图点会被压进这个集合,从一份CC教程里面学过来的机制,这样做节省资源,不用因为打死一只怪物就重新加载整张地图
    NSMutableSet *readyToReloadPoints;
    //
    NSMutableDictionary *animations;
    //
    NSMutableArray *blocksInformation;
}

@end

@implementation GameLayer

+(id)scene{
    CCScene *scene=[CCScene node];
    GameLayer *layer=[GameLayer node];
    [scene addChild:layer];
    return scene;
}

-(id)init{
	if(self=[super init]){
        //启用触控
        self.isTouchEnabled=YES;
        //载入图像
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_world.plist"];
        //加载动画
        [self loadAnimation];
        //加载方块信息
        [self loadBlockInformation];
        //添加调试用按钮
        CCMenuItem *plusButton=[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" block:^(id sender){currentFloor+=1;[self loadMap:YES];}];
        plusButton.anchorPoint=ccp(0,0);
        CCMenuItem *minusButton=[CCMenuItemImage itemWithNormalImage:@"ButtonMinus.png" selectedImage:@"ButtonMinusSel.png" block:^(id sender){currentFloor-=1;[self loadMap:YES];}];
        minusButton.anchorPoint=ccp(0,0);
        minusButton.position=ccp(0,60);
        CCMenu *buttonMenu=[CCMenu menuWithItems:plusButton,minusButton,nil];
        buttonMenu.anchorPoint=ccp(0,0);
        [buttonMenu setPosition:ccp(0,0)];
        [self addChild:buttonMenu z:100];
        //初始化需要的数值
        currentFloor=0;
        mapSprites=[[NSMutableArray alloc]init];
        //添加背景
		CCSprite *backgroundSprite=[[CCSprite alloc]initWithFile:@"gameBackground.png"];
        backgroundSprite.anchorPoint=ccp(0,0);
        [self addChild:backgroundSprite];
        [backgroundSprite release];
        //读入地图库
        gameMap=[[NSMutableArray alloc]initWithArray:[[self readPlistWithPlistName:@"MapInformation"]objectForKey:@"LevelMap"]];
        //画出地图
        [self loadMap:YES];
        
	}
	return self;
}

-(void)loadAnimation{
    animations=[[NSMutableDictionary alloc]init];
    NSMutableArray *animsArray=[[self readPlistWithPlistName:@"AnimationInformation"]objectForKey:@"AnimationInformation"];
    
    for(NSDictionary *animDictionary in animsArray){
        NSString *animName=[animDictionary objectForKey:@"AnimationID"];
        NSArray *animImages=[animDictionary objectForKey:@"AnimationFrames"];
        
        NSMutableArray *animFrames = [NSMutableArray array];
        for(NSString *animImage in animImages) {
            [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:animImage]];
        }
        CCAnimation *animation=[CCAnimation animationWithSpriteFrames:animFrames delay:0.5];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animName];
        [animations setObject:animation forKey:animName];
        NSLog(@"Animation:%@ Loaded!",animName);
        
    }
}

-(void)loadBlockInformation{
    blocksInformation=[[NSMutableArray alloc]init];
    NSMutableArray *blocksArray=[[self readPlistWithPlistName:@"BlockInformation"]objectForKey:@"BlockInformation"];
    
    for(NSDictionary *blockDictionary in blocksArray){
        [blocksInformation addObject:blockDictionary];
    }
}

-(void)loadMap:(BOOL)reloadAll{
    //如果reloadAll为true,就重载整张地图,如果为false,就只重载readyToReloadPoints中需要重载的地图点
    for(NSMutableArray *row in mapSprites){
        for(CCSprite *spriteToRemove in row){
            [self removeChild:spriteToRemove cleanup:YES];
        }
    }
    for(int i=0;i<11;i++){
        NSMutableArray *rowSprites=[[NSMutableArray alloc]init];
        for(int j=0;j<11;j++){
            int thisBlock=[[[[gameMap objectAtIndex:currentFloor]objectAtIndex:i]objectAtIndex:j]intValue];
            
            NSDictionary *currentBlockInformation=[blocksInformation objectAtIndex:thisBlock];
            
            
            if(thisBlock!=0){
                CCSprite *mapBlockSprite=[CCSprite spriteWithSpriteFrameName:[currentBlockInformation objectForKey:@"UsingImage"]];
                if(![[currentBlockInformation objectForKey:@"AnimationID"]isEqualToString:@""]){
                    [mapBlockSprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[animations objectForKey:[currentBlockInformation objectForKey:@"AnimationID"]]]]];
                }
                if(mapBlockSprite){
                    mapBlockSprite.anchorPoint=ccp(0,0);
                    mapBlockSprite.position=ccp(103+25*j,23+25*i);
                    [self addChild:mapBlockSprite];
                    [rowSprites addObject:mapBlockSprite];
                }
            }
        }
        [mapSprites addObject:rowSprites];
    }
}

-(NSMutableDictionary*)readPlistWithPlistName:(NSString*)plistName{
    NSString *error=nil;
    NSPropertyListFormat format;
    NSMutableDictionary *dict=nil;
    NSString *filePath=[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSData *plistXML=[[NSFileManager defaultManager]contentsAtPath:filePath];
    dict=(NSMutableDictionary*)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error];
    return dict;
}


-(void)dealloc{
    [super dealloc];
}

@end
