//
//  BuyLayer.m
//  MagicTower
//
//  Created by Bill on 12-10-31.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "BuyLayer.h"

@interface BuyLayer(){
    CCSprite *backgroundSprite;
    
    CCLabelTTF *infLabel;
    
    NSMutableArray *buyItems;
}
@end

@implementation BuyLayer

@synthesize delegate;

-(id)init{
    if(self=[super init]){
        backgroundSprite=[CCSprite spriteWithFile:@"buy_background.png"];
        backgroundSprite.anchorPoint=ccp(0,0);
        backgroundSprite.position=ccp(0,0);
        [self addChild:backgroundSprite];
        
        buyItems=[[[NSMutableArray alloc]init]autorelease];
        for(int i=0;i<4;i++){
            CCMenuItemLabel *buyItem=[[[CCMenuItemLabel alloc]init]autorelease];
            buyItem.anchorPoint=ccp(0.5,0);
            buyItem.position=ccp(240/2,240-(i+2)*40);
            [buyItems addObject:buyItem];
        }
        
        CCMenu *buyMenu=[CCMenu menuWithArray:buyItems];
        buyMenu.anchorPoint=ccp(0,0);
        buyMenu.position=ccp(0,0);
        [self addChild:buyMenu];
        
    }
    return self;
}

-(void)showWithThingsToSell:(NSDictionary*)shopInformation{

    NSString *shopTitle=[shopInformation objectForKey:@"ShopTitle"];
    
    infLabel=[CCLabelTTF labelWithString:shopTitle fontName:@"Marker Felt" fontSize:15];
    infLabel.anchorPoint=ccp(0.5,0);
    infLabel.position=ccp(240/2,240-40);
    [self addChild:infLabel];
    
    NSArray *thingsToSell=[shopInformation objectForKey:@"ThingsToSell"];
    
    NSAssert(thingsToSell.count==3,@"Only can sell three things!");
    
    for(int i=0;i<3;i++){
        NSDictionary *thingToSell=[thingsToSell objectAtIndex:i];
        
        NSString *itemString=[thingToSell objectForKey:@"ThingTitle"];
        
        CCLabelTTF *buyItemLabel=[CCLabelTTF labelWithString:itemString fontName:@"Marker Felt" fontSize:20];
        ((CCMenuItemLabel*)[buyItems objectAtIndex:i]).label=buyItemLabel;
        [((CCMenuItemLabel*)[buyItems objectAtIndex:i]) setBlock:^(id sender){
            [self thingSelectedWithInformation:thingToSell];
        }];
    }
    CCLabelTTF *buyItemLabel=[CCLabelTTF labelWithString:@"返回" fontName:@"Marker Felt" fontSize:20];
    ((CCMenuItemLabel*)[buyItems objectAtIndex:3]).label=buyItemLabel;
    [((CCMenuItemLabel*)[buyItems objectAtIndex:3]) setBlock:^(id sender){
        [self backClicked];
    }];
}
             
-(void)thingSelectedWithInformation:(NSDictionary*)thingInformation{
    if(delegate)[delegate thingSelectedWithThingInformation:thingInformation];
}

-(void)backClicked{
    if(delegate)[delegate backClickedWithLayer:self];
}

@end
