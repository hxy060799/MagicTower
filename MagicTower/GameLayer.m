//
//  GameLayer.m
//  MagicTower
//
//  Created by Bill on 12-10-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "Player.h"

@interface GameLayer(){
    //玩家当前位于的楼层.注意:第一层对应的索引为1,因为前面还有个序章
    NSInteger currentFloor;
    //游戏地图，三位数组[楼层,x,y](x<11,y<11)
    NSMutableArray *gameMap;
    //地图是通过11*11=121个精灵拼凑而成的,这是个二维数组
    NSMutableArray *mapSprites;
    //将要被移走的地图点,从一份教程里面学过来的机制,这样做节省资源,不用因为打死一只怪物就重新加载整张地图
    struct position readyToRemovePoint;
    //用于储存加载好的动画
    NSMutableDictionary *animations;
    //用于储存各种方块的信息
    NSMutableArray *blocksInformation;
    //用于储存楼层切换之后玩家的出生点
    NSMutableArray *floorBorn;
    
    Player *player;
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
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_monster.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_items.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"player.plist"];
        //加载动画
        [self loadAnimation];
        //加载方块信息
        [self loadBlockInformation];
        //添加调试用按钮
        CCMenuItem *plusButton=[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" block:^(id sender){currentFloor+=1;[self loadMap:YES];}];
        plusButton.anchorPoint=ccp(0,0);
        
        CCMenuItem *minusButton=[CCMenuItemImage itemWithNormalImage:@"ButtonMinus.png" selectedImage:@"ButtonMinusSel.png" block:^(id sender){currentFloor-=1;[self loadMap:YES];}];
        minusButton.anchorPoint=ccp(0,0);
        minusButton.position=ccp(0,35);
        
        CCMenuItem *leftButton=[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" block:^(id sender){[self playerMoveToX:player.position.x-1 Y:player.position.y];}];
        leftButton.anchorPoint=ccp(0,0);
        leftButton.position=ccp(380,35);
        
        CCMenuItem *rightButton=[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" block:^(id sender){[self playerMoveToX:player.position.x+1 Y:player.position.y];}];
        rightButton.anchorPoint=ccp(0,0);
        rightButton.position=ccp(450,35);
        
        CCMenuItem *upButton=[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" block:^(id sender){[self playerMoveToX:player.position.x Y:player.position.y+1];}];
        upButton.anchorPoint=ccp(0,0);
        upButton.position=ccp(415,70);
        
        CCMenuItem *downButton=[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" block:^(id sender){[self playerMoveToX:player.position.x Y:player.position.y-1];}];
        downButton.anchorPoint=ccp(0,0);
        downButton.position=ccp(415,0);
        
        CCMenu *buttonMenu=[CCMenu menuWithItems:plusButton,minusButton,leftButton,rightButton,upButton,downButton,nil];
        buttonMenu.anchorPoint=ccp(0,0);
        [buttonMenu setPosition:ccp(0,0)];
        
        [self addChild:buttonMenu z:100];
        //显示信息
        
        //初始化需要的数值
        currentFloor=0;
        mapSprites=[[NSMutableArray alloc]init];
        floorBorn=[[NSMutableArray alloc]init];
        //添加背景
		CCSprite *backgroundSprite=[[CCSprite alloc]initWithFile:@"gameBackground.png"];
        backgroundSprite.anchorPoint=ccp(0,0);
        [self addChild:backgroundSprite];
        [backgroundSprite release];
        //读入地图库
        gameMap=[[NSMutableArray alloc]initWithArray:[[self readPlistWithPlistName:@"MapInformation"]objectForKey:@"LevelMap"]];
        [floorBorn addObject:[[self readPlistWithPlistName:@"MapInformation"]objectForKey:@"UpStairBorn"]];
        [floorBorn addObject:[[self readPlistWithPlistName:@"MapInformation"]objectForKey:@"DownStairBorn"]];
        //画出地图
        [self loadMap:YES];
        //画出玩家
        player=[[Player alloc]init];
        struct position bornPosition=[self currentBornPlaceWithIsUp:YES];
        [player setPositionWithX:bornPosition.x AndY:bornPosition.y];
        [self addChild:player.sprite z:2];
	}
	return self;
}

-(struct position)currentBornPlaceWithIsUp:(BOOL)isUp{
    //用于返回对应楼层的出生点,isUp用于表示是否为向上一层
    struct position cPosition;
    if(isUp){
        cPosition.x=[[[[floorBorn objectAtIndex:0] objectAtIndex:currentFloor]valueForKey:@"x"]intValue];
        cPosition.y=[[[[floorBorn objectAtIndex:0] objectAtIndex:currentFloor]valueForKey:@"y"]intValue];
    }else{
        cPosition.x=[[[[floorBorn objectAtIndex:1] objectAtIndex:currentFloor]valueForKey:@"x"]intValue];
        cPosition.y=[[[[floorBorn objectAtIndex:1] objectAtIndex:currentFloor]valueForKey:@"y"]intValue];
    }
    return cPosition;
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
    if(reloadAll){
        for(NSMutableArray *row in mapSprites){
            for(CCSprite *spriteToRemove in row){
                [spriteToRemove removeFromParentAndCleanup:YES];
            }
        }
        [mapSprites removeAllObjects];
        for(int i=0;i<11;i++){
            NSMutableArray *rowSprites=[[NSMutableArray alloc]init];
            for(int j=0;j<11;j++){
                int thisBlock=[[[[gameMap objectAtIndex:currentFloor]objectAtIndex:i]objectAtIndex:j]intValue];
                
                NSDictionary *currentBlockInformation=[blocksInformation objectAtIndex:thisBlock];
                
                if(thisBlock>=0){
                    CCSprite *mapBlockSprite=[CCSprite spriteWithSpriteFrameName:[currentBlockInformation objectForKey:@"UsingImage"]];
                    if(![[currentBlockInformation objectForKey:@"AnimationID"]isEqualToString:@""]){
                        [mapBlockSprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[animations objectForKey:[currentBlockInformation objectForKey:@"AnimationID"]]]]];
                    }
                    if(mapBlockSprite){
                        mapBlockSprite.anchorPoint=ccp(0,0);
                        mapBlockSprite.position=ccp(103+25*j,23+25*i);
                        [self addChild:mapBlockSprite z:0];
                        [rowSprites addObject:mapBlockSprite];
                        
                    }
                }
            }
            [mapSprites addObject:rowSprites];
        }
    }else{
        CCSprite *spriteToRemove=[[mapSprites objectAtIndex:readyToRemovePoint.y]objectAtIndex:readyToRemovePoint.x];
        [spriteToRemove removeFromParentAndCleanup:YES];
        
        NSDictionary *currentBlockInformation=[blocksInformation objectAtIndex:0];
        CCSprite *mapBlockSprite=[CCSprite spriteWithSpriteFrameName:[currentBlockInformation objectForKey:@"UsingImage"]];
        mapBlockSprite.anchorPoint=ccp(0,0);
        mapBlockSprite.position=ccp(103+25*readyToRemovePoint.x,23+25*readyToRemovePoint.y);
        [self addChild:mapBlockSprite z:0];
        
        [[mapSprites objectAtIndex:readyToRemovePoint.y]replaceObjectAtIndex:readyToRemovePoint.x withObject:mapBlockSprite];

        
        [[[gameMap objectAtIndex:currentFloor]objectAtIndex:readyToRemovePoint.y]replaceObjectAtIndex:readyToRemovePoint.x withObject:[NSNumber numberWithInt:0]];
        
        readyToRemovePoint.x=0;
        readyToRemovePoint.y=0;
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

-(void)playerMoveToX:(int)xTo Y:(int)yTo{
    int toBlock=[[[[gameMap objectAtIndex:currentFloor]objectAtIndex:yTo]objectAtIndex:xTo]intValue];
    NSDictionary *blockInf=[blocksInformation objectAtIndex:toBlock];
    NSString *blockType=[[blocksInformation objectAtIndex:toBlock]valueForKey:@"Type"];
    
    if([blockType isEqualToString:@"Air"]){
        [player setPositionWithX:xTo AndY:yTo];
    }else if([blockType isEqualToString:@"Upstairs"]){
        currentFloor+=1;
        [self loadMap:YES];
        struct position bornPosition=[self currentBornPlaceWithIsUp:YES];
        [player setPositionWithX:bornPosition.x AndY:bornPosition.y];
    }else if([blockType isEqualToString:@"Downstairs"]){
        currentFloor-=1;
        [self loadMap:YES];
        struct position bornPosition=[self currentBornPlaceWithIsUp:NO];
        [player setPositionWithX:bornPosition.x AndY:bornPosition.y];
    }else if([blockType isEqualToString:@"Item"]){
        readyToRemovePoint.x=xTo;
        readyToRemovePoint.y=yTo;
        [self loadMap:NO];
    }else if([blockType isEqualToString:@"Monster"]){
        NSLog(@"%@",[blockInf valueForKey:@"HP"]);
        readyToRemovePoint.x=xTo;
        readyToRemovePoint.y=yTo;
        [self loadMap:NO];
    }
}

-(void)dealloc{
    [super dealloc];
}

@end
