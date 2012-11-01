//
//  HitLayer.h
//  MagicTower
//
//  Created by Bill on 12-10-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"

@class HitLayer;

@protocol HitLayerDelegate <NSObject>
-(void)hitFinishedWithLayer:(HitLayer*)layer;
@end

@interface HitLayer : CCLayer {
    id<HitLayerDelegate>delegate;
}

@property(retain,nonatomic)id<HitLayerDelegate>delegate;

-(void)startHitWithPlayer:(Player*)player MonsterHP:(int)hp Attack:(int)attack Defence:(int)defence HitCount:(int)hitCount MonsterName:(NSString*)monsterName ImageData:(NSDictionary*)imageData;
@end

