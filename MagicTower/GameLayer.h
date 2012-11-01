//
//  GameLayer.h
//  MagicTower
//
//  Created by Bill on 12-10-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"
#import "HitLayer.h"
#import "BuyLayer.h"

@interface GameLayer : CCLayer<HitLayerDelegate,BuyLayerDelegate>{

}

typedef enum{
    MTStairsWayUpstairs,
    MTStairsWayDownstairs,
}MTStairsWay;

+(id)scene;

@end
