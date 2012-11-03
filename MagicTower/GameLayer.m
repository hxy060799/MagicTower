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
    //游戏地图，三位数组[楼层,y,x](x<11,y<11)
    NSMutableArray *gameMap;
    //地图是通过11*11=121个精灵拼凑而成的,这是个二维数组
    NSMutableArray *mapSprites;
    //用于储存加载好的动画
    NSMutableDictionary *animations;
    //用于储存各种方块的信息
    NSMutableArray *blocksInformation;
    //用于储存楼层切换之后玩家的出生点
    NSMutableArray *floorBorn;
    //
    NSMutableArray *shopsInformation;
    //
    NSMutableArray *dialogInformation;
    
    Player *player;
    
    CCLabelTTF *hpLabel;
    CCLabelTTF *attackLabel;
    CCLabelTTF *defenceLabel;
    
    CCLabelTTF *redKeyLabel;
    CCLabelTTF *yellowKeyLabel;
    CCLabelTTF *blueKeyLabel;
    
    CCLabelTTF *moneyLabel;
    CCLabelTTF *expLabel;
    CCLabelTTF *levelLabel;
    
    BOOL isRunningAnimation;
    
    struct MTPlot{
        //主线-救公主
        BOOL princessTalkedTo;
        //副1-帮助公主寻找十字架
        BOOL fairyFirstTalkedTo;
        BOOL crossFound;
        BOOL fairySecondTalkedTo;
        //副2-帮助小偷找到镐子
        BOOL thiefFirstTalkedTo;
        BOOL stoveFound;
        BOOL thiefSecondTalkedTo;
    };
    //游戏剧情
    struct MTPlot gamePlot;
}

@end

@implementation GameLayer

#pragma mark - Create a scene 
+(id)scene{
    CCScene *scene=[CCScene node];
    GameLayer *layer=[GameLayer node];
    [scene addChild:layer];
    return scene;
}

#pragma mark - init Methood

-(id)init{
	if(self=[super init]){
        
        gamePlot.princessTalkedTo=NO;
        gamePlot.fairyFirstTalkedTo=NO;
        gamePlot.crossFound=NO;
        gamePlot.fairySecondTalkedTo=NO;
        gamePlot.thiefFirstTalkedTo=NO;
        gamePlot.stoveFound=NO;
        gamePlot.thiefSecondTalkedTo=NO;
        
        //启用触控
        self.isTouchEnabled=YES;
        //载入图像
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_world.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_monster.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_items.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"player.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_doors.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"block_person.plist"];
        //加载动画
        [self loadAnimation];
        //加载方块信息
        [self loadBlockInformation];
        //加载商店信息
        [self loadShops];
        [self loadDialogs];
        //添加按钮
        CCMenuItem *plusButton=[CCMenuItemImage itemWithNormalImage:@"ButtonPlus.png" selectedImage:@"ButtonPlusSel.png" block:^(id sender){currentFloor+=1;[self reloadMapWithX:-1 Y:-1];}];
        plusButton.anchorPoint=ccp(0,0);
        
        CCMenuItem *minusButton=[CCMenuItemImage itemWithNormalImage:@"ButtonMinus.png" selectedImage:@"ButtonMinusSel.png" block:^(id sender){currentFloor-=1;[self reloadMapWithX:-1 Y:-1];}];
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
        //初始化需要的数值
        currentFloor=0;
        //添加背景
		CCSprite *backgroundSprite=[[CCSprite alloc]initWithFile:@"gameBackground.png"];
        backgroundSprite.anchorPoint=ccp(0,0);
        [self addChild:backgroundSprite z:0];
        [backgroundSprite release];
        //读入地图库
        gameMap=[[NSMutableArray alloc]initWithArray:[[self readPlistWithPlistName:@"MapInformation"]objectForKey:@"LevelMap"]];
        floorBorn=[[NSMutableArray alloc]init];
        [floorBorn addObject:[[self readPlistWithPlistName:@"MapInformation"]objectForKey:@"UpStairBorn"]];
        [floorBorn addObject:[[self readPlistWithPlistName:@"MapInformation"]objectForKey:@"DownStairBorn"]];
        //画出地图
        [self initMapSprites];
        [self reloadMapWithX:-1 Y:-1];
        //画出玩家
        player=[[Player alloc]init];
        struct position bornPosition=[self currentBornPositionWithIsUp:MTStairsWayUpstairs];
        [player setPositionWithX:bornPosition.x AndY:bornPosition.y];
        [self addChild:player.sprite z:3];
        //显示信息
        hpLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"生命:%i",player.hp] fontName:@"Marker Felt" fontSize:15.0];
        hpLabel.color=ccBLACK;
        hpLabel.anchorPoint=ccp(0,0);
        hpLabel.position=ccp(20,300);
        [self addChild:hpLabel z:200];
        
        attackLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"攻击:%i",player.attack] fontName:@"Marker Felt" fontSize:15.0];
        attackLabel.color=ccBLACK;
        attackLabel.anchorPoint=ccp(0,0);
        attackLabel.position=ccp(20,280);
        [self addChild:attackLabel z:200];
        
        defenceLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"防御:%i",player.defence] fontName:@"Marker Felt" fontSize:15.0];
        defenceLabel.color=ccBLACK;
        defenceLabel.anchorPoint=ccp(0,0);
        defenceLabel.position=ccp(20,260);
        [self addChild:defenceLabel z:200];
        
        redKeyLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"红钥匙:%i",player.redKeyCount] fontName:@"Marker Felt" fontSize:15.0];
        redKeyLabel.color=ccBLACK;
        redKeyLabel.anchorPoint=ccp(0,0);
        redKeyLabel.position=ccp(20,240);
        [self addChild:redKeyLabel z:200];
        
        yellowKeyLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"黄钥匙:%i",player.yellowKeyCount] fontName:@"Marker Felt" fontSize:15.0];
        yellowKeyLabel.color=ccBLACK;
        yellowKeyLabel.anchorPoint=ccp(0,0);
        yellowKeyLabel.position=ccp(20,220);
        [self addChild:yellowKeyLabel z:200];
        
        blueKeyLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"蓝钥匙:%i",player.blueKeyCount] fontName:@"Marker Felt" fontSize:15.0];
        blueKeyLabel.color=ccBLACK;
        blueKeyLabel.anchorPoint=ccp(0,0);
        blueKeyLabel.position=ccp(20,200);
        [self addChild:blueKeyLabel z:200];
        
        moneyLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"金币:%i",player.money] fontName:@"Marker Felt" fontSize:15.0];
        moneyLabel.color=ccBLACK;
        moneyLabel.anchorPoint=ccp(0,0);
        moneyLabel.position=ccp(20,180);
        [self addChild:moneyLabel z:200];
        
        expLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"经验:%i",player.exp] fontName:@"Marker Felt" fontSize:15.0];
        expLabel.color=ccBLACK;
        expLabel.anchorPoint=ccp(0,0);
        expLabel.position=ccp(20,160);
        [self addChild:expLabel z:200];
        
        levelLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"等级:%i",player.level] fontName:@"Marker Felt" fontSize:15.0];
        levelLabel.color=ccBLACK;
        levelLabel.anchorPoint=ccp(0,0);
        levelLabel.position=ccp(20,140);
        [self addChild:levelLabel z:200];
        
        //HitLayer *hitLayer=[[[HitLayer alloc]init]autorelease];
        //hitLayer.anchorPoint=ccp(0,0);
        //hitLayer.position=ccp(480/2-116,320/2-51);
        //[self addChild:hitLayer z:100];
        
        //BuyLayer *buyLayer=[[[BuyLayer alloc]init]autorelease];
        //buyLayer.position=ccp(480/2-120,320/2-120);
        //[buyLayer showWithThingsToSell:[shopsInformation objectAtIndex:1]];
        //[self addChild:buyLayer z:100];
        
        //DialogLayer *dialogLayer=[[[DialogLayer alloc]init]autorelease];
        //[dialogLayer showWithDialogInformation:[dialogInformation objectAtIndex:0]];
        //dialogLayer.position=ccp(480/2-75,320/2-25);
        //dialogLayer.delegate=self;
        //[self addChild:dialogLayer z:100];
        
	}
	return self;
}

#pragma mark - BuyLayerDelegate

-(void)backClickedWithLayer:(BuyLayer*)layer{
    [self removeChild:layer cleanup:YES];
    isRunningAnimation=NO;
}

-(void)thingSelectedWithThingInformation:(NSDictionary *)thingInformation{
    NSDictionary *thingGet=[thingInformation objectForKey:@"ThingGet"];
    NSDictionary *thingCost=[thingInformation objectForKey:@"ThingCost"];
    
    NSString *thingGetType=[thingGet objectForKey:@"ThingType"];
    NSString *thingGetValue=[thingGet objectForKey:@"ThingValue"];
    
    NSString *thingCostType=[thingCost objectForKey:@"ThingType"];
    int thingCostValue=[[thingCost objectForKey:@"ThingValue"]intValue];
    //!!!!
    if([thingCostType isEqualToString:@"Money"]){
        if(player.money>=thingCostValue){
            player.money-=thingCostValue;
        }else{
            return;
        }
    }else if([thingCostType isEqualToString:@"Exp"]){
        if(player.exp>=thingCostValue){
            player.exp-=thingCostValue;
        }else{
            return;
        }
    }else if([thingCostType isEqualToString:@"RedKey"]){
        if(player.redKeyCount>=thingCostValue){
            player.redKeyCount-=thingCostValue;
        }else{
            return;
        }
    }else if([thingCostType isEqualToString:@"BlueKey"]){
        if(player.blueKeyCount>=thingCostValue){
            player.blueKeyCount-=thingCostValue;
        }else{
            return;
        }
    }else if([thingCostType isEqualToString:@"YellowKey"]){
        if(player.yellowKeyCount>=thingCostValue){
            player.yellowKeyCount-=thingCostValue;
        }else{
            return;
        }
    }
    [player setPlayerInformationWithString:thingGetType StringValue:thingGetValue Append:YES];
    [self updateInformationLabel];
}

#pragma mark - Methods for labels

-(void)updateInformationLabel{
    [hpLabel setString:[NSString stringWithFormat:@"生命:%i",player.hp]];
    [attackLabel setString:[NSString stringWithFormat:@"攻击:%i",player.attack]];
    [defenceLabel setString:[NSString stringWithFormat:@"防御:%i",player.defence]];
    [redKeyLabel setString:[NSString stringWithFormat:@"红钥匙:%i",player.redKeyCount]];
    [yellowKeyLabel setString:[NSString stringWithFormat:@"黄钥匙:%i",player.yellowKeyCount]];
    [blueKeyLabel setString:[NSString stringWithFormat:@"蓝钥匙:%i",player.blueKeyCount]];
    [moneyLabel setString:[NSString stringWithFormat:@"金币:%i",player.money]];
    [expLabel setString:[NSString stringWithFormat:@"经验:%i",player.exp]];
    [levelLabel setString:[NSString stringWithFormat:@"等级:%i",player.level]];
}

#pragma mark Methods for loading

-(void)loadShops{
    shopsInformation=[[NSMutableArray alloc]init];
    NSMutableArray *shopsArray=[[self readPlistWithPlistName:@"ShopInformation"]objectForKey:@"ShopInformation"];
    
    for(NSDictionary *shopDictionary in shopsArray){
        [shopsInformation addObject:shopDictionary];
    }  
}

-(void)loadDialogs{
    dialogInformation=[[NSMutableArray alloc]init];
    NSMutableArray *dialogsArray=[[self readPlistWithPlistName:@"DialogsInformation"]objectForKey:@"DialogsInformation"];
    
    for(NSArray *dialogDictionary in dialogsArray){
        [dialogInformation addObject:dialogDictionary];
    }   
}

-(void)loadAnimation{
    animations=[[NSMutableDictionary alloc]init];
    NSMutableArray *animsArray=[[self readPlistWithPlistName:@"AnimationInformation"]objectForKey:@"AnimationInformation"];
    
    for(NSDictionary *animDictionary in animsArray){
        NSString *animName=[animDictionary objectForKey:@"AnimationID"];
        NSArray *animImages=[animDictionary objectForKey:@"AnimationFrames"];
        float delay=[[animDictionary objectForKey:@"Delay"]floatValue];
        
        NSMutableArray *animFrames = [NSMutableArray array];
        for(NSString *animImage in animImages) {
            [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:animImage]];
        }
        CCAnimation *animation=[CCAnimation animationWithSpriteFrames:animFrames delay:(delay==0)?0.5:delay];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:animName];
        [animations setObject:animation forKey:animName];
    }
}

-(void)loadBlockInformation{
    blocksInformation=[[NSMutableArray alloc]init];
    NSMutableArray *blocksArray=[[self readPlistWithPlistName:@"BlockInformation"]objectForKey:@"BlockInformation"];
    
    for(NSDictionary *blockDictionary in blocksArray){
        [blocksInformation addObject:blockDictionary];
    }
}

-(void)initMapSprites{
    mapSprites=[[NSMutableArray alloc]init];
    for(int i=0;i<11;i++){
        NSMutableArray *rowSprites=[[NSMutableArray alloc]init];
        for(int j=0;j<11;j++){
            
            CCSprite *mapBlockSprite=[[[CCSprite alloc]init]autorelease];
            mapBlockSprite.anchorPoint=ccp(0,0);
            mapBlockSprite.position=ccp(103+25*j,23+25*i);
            [self addChild:mapBlockSprite z:2];
            [rowSprites addObject:mapBlockSprite];
            
        }
        [mapSprites addObject:rowSprites];
    }
}

#pragma mark - Map editing methods

-(struct position)currentBornPositionWithIsUp:(MTStairsWay)stairsWay{
    //用于返回对应楼层的出生点
    struct position cPosition;
    if(stairsWay==MTStairsWayUpstairs){
        cPosition.x=[[[[floorBorn objectAtIndex:0] objectAtIndex:currentFloor]valueForKey:@"x"]intValue];
        cPosition.y=[[[[floorBorn objectAtIndex:0] objectAtIndex:currentFloor]valueForKey:@"y"]intValue];
    }else{
        cPosition.x=[[[[floorBorn objectAtIndex:1] objectAtIndex:currentFloor]valueForKey:@"x"]intValue];
        cPosition.y=[[[[floorBorn objectAtIndex:1] objectAtIndex:currentFloor]valueForKey:@"y"]intValue];
    }
    return cPosition;
}  

-(void)reloadMapWithX:(int)x Y:(int)y{
    //如果两个坐标都是-1就重载整个地图
    if(x==-1&&y==-1){
        for(int i=0;i<11;i++){
            for(int j=0;j<11;j++){
                [self reloadMapBlockWithX:j Y:i];
            }
        }
    }else{
        [self reloadMapBlockWithX:x Y:y];
    }
}

-(void)replaceBlockWithFloor:(int)floor X:(int)x Y:(int)y Block:(int)block{
    [[[gameMap objectAtIndex:floor]objectAtIndex:y]setObject:[NSNumber numberWithInt:block] atIndex:x];
    if(floor==currentFloor){
        [self reloadMapWithX:x Y:y];
    }
}

-(void)setBlockZWithX:(int)x Y:(int)y Z:(int)z{
    CCSprite *sprite=[[mapSprites objectAtIndex:y]objectAtIndex:x];
    [sprite setZOrder:z];
    [self reloadMapWithX:x Y:y];
}

-(void)reloadMapBlockWithX:(int)bX Y:(int)bY{
    CCSprite *spriteToReload=[[mapSprites objectAtIndex:bY]objectAtIndex:bX];
    [spriteToReload stopAllActions];
    int thisBlock=[self blockAtFloor:currentFloor X:bX Y:bY Full:NO];
    NSDictionary *currentBlockInformation=[blocksInformation objectAtIndex:thisBlock];
    NSString *fileName=[currentBlockInformation valueForKey:@"UsingImage"];
    CCSpriteFrame* myFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:fileName];
    [spriteToReload setDisplayFrame:myFrame];
    if(![[currentBlockInformation objectForKey:@"AnimationID"]isEqualToString:@""]){
        [spriteToReload runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[animations objectForKey:[currentBlockInformation objectForKey:@"AnimationID"]]]]];
    }
}

-(int)blockAtFloor:(int)floor X:(int)x Y:(int)y Full:(BOOL)full{
    if(full){
        return [[[[gameMap objectAtIndex:floor]objectAtIndex:y]objectAtIndex:x]intValue];
    }else{
        return [[[[gameMap objectAtIndex:floor]objectAtIndex:y]objectAtIndex:x]intValue]%100;
    }
}

#pragma mark Basic methods

-(NSMutableDictionary*)readPlistWithPlistName:(NSString*)plistName{
    NSString *error=nil;
    NSPropertyListFormat format;
    NSMutableDictionary *dict=nil;
    NSString *filePath=[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSData *plistXML=[[NSFileManager defaultManager]contentsAtPath:filePath];
    dict=(NSMutableDictionary*)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error];
    return dict;
}

#pragma mark Method for player

-(void)playerMoveToX:(int)xTo Y:(int)yTo{
    if(isRunningAnimation)return;
    if(xTo>10||yTo>10||xTo<0||yTo<0)return;
    
    int toBlock=[self blockAtFloor:currentFloor X:xTo Y:yTo Full:NO];
    NSDictionary *blockInf=[blocksInformation objectAtIndex:toBlock];
    NSString *blockType=[[blocksInformation objectAtIndex:toBlock]valueForKey:@"Type"];
    
    if(![blockType isEqualToString:@"Wall"]){
        if(xTo<player.position.x){
            [player.sprite runAction:[CCAnimate actionWithAnimation:[animations objectForKey:@"PlayerGoLeftAnimation"]]];
        }else if(xTo>player.position.x){
            [player.sprite runAction:[CCAnimate actionWithAnimation:[animations objectForKey:@"PlayerGoRightAnimation"]]];
        }else if(yTo>player.position.y){
            [player.sprite runAction:[CCAnimate actionWithAnimation:[animations objectForKey:@"PlayerGoUpAnimation"]]];
        }else if(yTo<player.position.y){
            [player.sprite runAction:[CCAnimate actionWithAnimation:[animations objectForKey:@"PlayerGoDownAnimation"]]];
        }
    }
    
    if([blockType isEqualToString:@"Air"]){
        //如果是空气则走过去
        [player setPositionWithX:xTo AndY:yTo];
    }else if([blockType isEqualToString:@"Upstairs"]){
        //如果是上楼梯则先把地图载入到上一层,然后把玩家移动到上一层的起始点
        currentFloor+=1;
        [self reloadMapWithX:-1 Y:-1];
        
        struct position bornPosition=[self currentBornPositionWithIsUp:MTStairsWayUpstairs];
        [player setPositionWithX:bornPosition.x AndY:bornPosition.y];
    }else if([blockType isEqualToString:@"Downstairs"]){
        //如果是下楼梯则先把地图载入到下一层,然后把玩家移动到下一层的起始点
        currentFloor-=1;
        [self reloadMapWithX:-1 Y:-1];
        
        struct position bornPosition=[self currentBornPositionWithIsUp:MTStairsWayDownstairs];
        [player setPositionWithX:bornPosition.x AndY:bornPosition.y];
    }else if([blockType isEqualToString:@"Item"]){
        //如果是物品则拾起它
        NSArray *thingsToGive=[blockInf valueForKey:@"ThingsToGive"];
        
        for(NSDictionary *thingToGive in thingsToGive){
            
            NSString *thingType=[thingToGive objectForKey:@"Type"];
            NSString *thingValue=[thingToGive objectForKey:@"Value"];
            
            [player setPlayerInformationWithString:thingType StringValue:thingValue Append:YES];
            [self updateInformationLabel];
        }
        
        //把物品移走
        [self replaceBlockWithFloor:currentFloor X:xTo Y:yTo Block:0];
    }else if([blockType isEqualToString:@"Monster"]){
        //如果是怪物
        int attack=[[blockInf valueForKey:@"Attack"]intValue];
        int defence=[[blockInf valueForKey:@"Defence"]intValue];
        int hp=[[blockInf valueForKey:@"HP"]intValue];
        
        //计算打斗回合次数,如果打得过返回一个正整数,如果打不过返回-1
        int hitCount=[player checkWhoWinWithAttack:attack Defence:defence HP:hp];
        if(hitCount>-1){
            NSMutableDictionary *imageData=[[[NSMutableDictionary alloc]init]autorelease];
            [imageData setObject:[blockInf objectForKey:@"UsingImage"] forKey:@"UsingImage"];
            
            HitLayer *hitLayer=[[[HitLayer alloc]init]autorelease];
            hitLayer.anchorPoint=ccp(0,0);
            hitLayer.position=ccp(480/2-116,320/2-51);
            hitLayer.delegate=self;
            isRunningAnimation=YES;
            [self addChild:hitLayer z:100];
            [hitLayer startHitWithPlayer:player MonsterHP:hp Attack:attack Defence:defence HitCount:hitCount MonsterName:[blockInf objectForKey:@"Name"] ImageData:imageData];
            
            //刷新生命
            player.hp=[[[player checkHPWithAttack:attack Defence:defence HP:hp Time:hitCount]objectForKey:@"AHP"]intValue];
            //得到金币
            player.money+=[[blockInf objectForKey:@"Money"]intValue];
            //得到经验
            player.exp+=[[blockInf objectForKey:@"Exp"]intValue];
            
            [self replaceBlockWithFloor:currentFloor X:xTo Y:yTo Block:0];
            [self updateInformationLabel];
        }else{
            NSLog(@"打不过");
        }
    }else if([blockType isEqualToString:@"Door"]){
        
        if([[blockInf valueForKey:@"DoorAnimationType"]isEqualToString:@"TwoHalf"]){
            NSString *doorColor=[blockInf valueForKey:@"Color"];
            
            if([doorColor isEqualToString:@"Red"]){
                if(player.redKeyCount<=0){
                    return;
                }else{
                    player.redKeyCount--;
                }
            }else if([doorColor isEqualToString:@"Blue"]){
                if(player.blueKeyCount<=0){
                    return;
                }else{
                    player.blueKeyCount--;
                }
            }else if([doorColor isEqualToString:@"Yellow"]){
                if(player.yellowKeyCount<=0){
                    return;
                }else{
                    player.yellowKeyCount--;
                }
            }
            
            [self replaceBlockWithFloor:currentFloor X:xTo Y:yTo Block:0];
            
            [self updateInformationLabel];
            
            [self setBlockZWithX:xTo Y:yTo Z:1];
            
            CCSprite *leftDoor=[CCSprite spriteWithSpriteFrameName:[blockInf valueForKey:@"LeftDoorImage"]];
            leftDoor.anchorPoint=ccp(0,0);
            leftDoor.position=ccp(103+25*xTo,23+25*yTo);
            [self addChild:leftDoor z:1];
            
            CCSprite *rightDoor=[CCSprite spriteWithSpriteFrameName:[blockInf valueForKey:@"RightDoorImage"]];
            rightDoor.anchorPoint=ccp(0,0);
            rightDoor.position=ccp(103+25*xTo+13,23+25*yTo);
            [self addChild:rightDoor z:1];
            
            isRunningAnimation=YES;
            
            CCMoveBy *leftDoorMoveBy=[CCMoveBy actionWithDuration:0.2 position:ccp(-13,0)];
            CCMoveBy *rightDoorMoveBy=[CCMoveBy actionWithDuration:0.2 position:ccp(13,0)];
            CCCallBlock *animationEndBlock=[CCCallBlock actionWithBlock:^(void){
                [self setBlockZWithX:xTo Y:yTo Z:2];
                [leftDoor removeFromParentAndCleanup:YES];
                [rightDoor removeFromParentAndCleanup:YES];
                isRunningAnimation=NO;
            }];
            
            [leftDoor runAction:[CCSequence actions:leftDoorMoveBy,animationEndBlock,nil]];
            [rightDoor runAction:rightDoorMoveBy];
        }else if([[blockInf valueForKey:@"DoorAnimationType"]isEqualToString:@"OneBody"]){
            [self replaceBlockWithFloor:currentFloor X:xTo Y:yTo Block:0];
            
            [self setBlockZWithX:xTo Y:yTo Z:1];
            CCSprite *gateDoor=[CCSprite spriteWithSpriteFrameName:[blockInf valueForKey:@"UsingImage"]];
            gateDoor.anchorPoint=ccp(0,0);
            gateDoor.position=ccp(103+25*xTo,23+25*yTo);
            [self addChild:gateDoor z:1];
            
            isRunningAnimation=YES;
            
            CCMoveBy *gateDoorMoveBy=[CCMoveBy actionWithDuration:0.2 position:ccp(0,-26)];
            CCCallBlock *animationEndBlock=[CCCallBlock actionWithBlock:^(void){
                [self setBlockZWithX:xTo Y:yTo Z:1];
                [gateDoor removeFromParentAndCleanup:YES];
                isRunningAnimation=NO;
            }];
            
            [gateDoor runAction:[CCSequence actions:gateDoorMoveBy,animationEndBlock,nil]];
        }
        
    }else if([blockType isEqualToString:@"Person"]){
        int fullToBlock=[self blockAtFloor:currentFloor X:xTo Y:yTo Full:YES];
        int extraInf=fullToBlock/100;
        NSLog(@"Load Shop %i",extraInf);
        if(extraInf>0){
            if(extraInf<7){
                BuyLayer *buyLayer=[[[BuyLayer alloc]init]autorelease];
                buyLayer.position=ccp(480/2-120,320/2-120);
                isRunningAnimation=YES;
                buyLayer.delegate=self;
                [buyLayer showWithThingsToSell:[shopsInformation objectAtIndex:extraInf-1]];
                [self addChild:buyLayer z:100];
            }else{
                isRunningAnimation=YES;
                
                DialogLayer *dialogLayer=[[[DialogLayer alloc]init]autorelease];
                [dialogLayer showWithDialogInformation:[dialogInformation objectAtIndex:extraInf-3]];
                dialogLayer.position=ccp(480/2-75,320/2-25);
                dialogLayer.delegate=self;
                [self addChild:dialogLayer z:100];
            }
        }else{
            [self replaceBlockWithFloor:currentFloor X:xTo Y:yTo Block:0];
        }
    }else if([blockType isEqualToString:@"Fairy"]){
        if(!gamePlot.fairyFirstTalkedTo){
            isRunningAnimation=YES;
            
            DialogLayer *dialogLayer=[[[DialogLayer alloc]init]autorelease];
            [dialogLayer showWithDialogInformation:[dialogInformation objectAtIndex:0]];
            dialogLayer.position=ccp(480/2-75,320/2-25);
            dialogLayer.delegate=self;
            [self addChild:dialogLayer z:100];
        }else if(gamePlot.crossFound==YES&&gamePlot.fairySecondTalkedTo==NO){
            isRunningAnimation=YES;
            
            DialogLayer *dialogLayer=[[[DialogLayer alloc]init]autorelease];
            [dialogLayer showWithDialogInformation:[dialogInformation objectAtIndex:1]];
            dialogLayer.position=ccp(480/2-75,320/2-25);
            dialogLayer.delegate=self;
            [self addChild:dialogLayer z:100];
        }
    }else if([blockType isEqualToString:@"LuckyCross"]){
        gamePlot.crossFound=YES;
        [self replaceBlockWithFloor:currentFloor X:xTo Y:yTo Block:0];
    }else if([blockType isEqualToString:@"Thief"]) {
        
        if(!gamePlot.thiefFirstTalkedTo){
            isRunningAnimation=YES;
            
            DialogLayer *dialogLayer=[[[DialogLayer alloc]init]autorelease];
            [dialogLayer showWithDialogInformation:[dialogInformation objectAtIndex:2]];
            dialogLayer.position=ccp(480/2-75,320/2-25);
            dialogLayer.delegate=self;
            [self addChild:dialogLayer z:100];
        }else if(gamePlot.stoveFound&&gamePlot.thiefSecondTalkedTo==NO){
            isRunningAnimation=YES;
            
            DialogLayer *dialogLayer=[[[DialogLayer alloc]init]autorelease];
            [dialogLayer showWithDialogInformation:[dialogInformation objectAtIndex:3]];
            dialogLayer.position=ccp(480/2-75,320/2-25);
            dialogLayer.delegate=self;
            [self addChild:dialogLayer z:100];
        }
    }else if([blockType isEqualToString:@"Stove"]){
        gamePlot.stoveFound=YES;
        [self replaceBlockWithFloor:currentFloor X:xTo Y:yTo Block:0];
    }else if([blockType isEqualToString:@"Princess"]){
        if(!gamePlot.princessTalkedTo){
            isRunningAnimation=YES;
            
            DialogLayer *dialogLayer=[[[DialogLayer alloc]init]autorelease];
            [dialogLayer showWithDialogInformation:[dialogInformation objectAtIndex:8]];
            dialogLayer.position=ccp(480/2-75,320/2-25);
            dialogLayer.delegate=self;
            [self addChild:dialogLayer z:100];
        }
    }
}

#pragma mark - HitLayerDelegate

-(void)hitFinishedWithLayer:(HitLayer *)layer{
    [layer removeFromParentAndCleanup:YES];
    isRunningAnimation=NO;
}

#pragma mark - DialogLayerDelegate

-(void)dialogEndWithThingsToGive:(NSArray*)thingsToGive Layer:(DialogLayer *)layer ExtraInformation:(NSString *)extraInf{
    for(NSDictionary *thingToGive in thingsToGive){
        [player setPlayerInformationWithString:[thingToGive objectForKey:@"Type"] StringValue:[thingToGive objectForKey:@"Value"] Append:YES];
    }
    [layer removeFromParentAndCleanup:YES];
    [self updateInformationLabel];
    isRunningAnimation=NO;
    
    if([extraInf isEqualToString:@"FairyFirst"]){
        [self replaceBlockWithFloor:currentFloor X:5 Y:2 Block:0];
        [self replaceBlockWithFloor:currentFloor X:4 Y:2 Block:61];
        gamePlot.fairyFirstTalkedTo=YES;
    }else if([extraInf isEqualToString:@"FairySecond"]){
        gamePlot.fairySecondTalkedTo=YES;
        [self replaceBlockWithFloor:20 X:5 Y:3 Block:4];
    }else if([extraInf isEqualToString:@"ThiefFirst"]){
        gamePlot.thiefFirstTalkedTo=YES;
        [self replaceBlockWithFloor:2 X:1 Y:4 Block:0];
    }else if([extraInf isEqualToString:@"ThiefSecond"]){
        gamePlot.thiefSecondTalkedTo=YES;
        [self replaceBlockWithFloor:4 X:5 Y:10 Block:0];
        
        [self replaceBlockWithFloor:18 X:5 Y:1 Block:0];
        [self replaceBlockWithFloor:18 X:5 Y:2 Block:0];
    }else if([extraInf isEqualToString:@"2FloorMan"]){
        [self replaceBlockWithFloor:2 X:7 Y:0 Block:0];
    }else if([extraInf isEqualToString:@"2FloorWoman"]){
        [self replaceBlockWithFloor:2 X:9 Y:0 Block:0];
    }else if([extraInf isEqualToString:@"15FloorMan"]){
        [self replaceBlockWithFloor:2 X:4 Y:7 Block:0];
    }else if([extraInf isEqualToString:@"15FloorWoman"]){
        [self replaceBlockWithFloor:2 X:6 Y:7 Block:0];
    }else if([extraInf isEqualToString:@"Princess"]){
        gamePlot.princessTalkedTo=YES;
        [self replaceBlockWithFloor:18 X:10 Y:0 Block:4];
    }
}

#pragma mark - Memory management

-(void)dealloc{
    [super dealloc];
}

@end
