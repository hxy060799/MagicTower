//
//  BuyLayer.h
//  MagicTower
//
//  Created by Bill on 12-10-31.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class BuyLayer;

@protocol BuyLayerDelegate<NSObject>
-(void)thingSelectedWithThingInformation:(NSDictionary*)thingInformation;
-(void)backClickedWithLayer:(BuyLayer*)layer;
@end

@interface BuyLayer : CCLayer {
    id<BuyLayerDelegate>delegate;
}

@property(retain,nonatomic)id<BuyLayerDelegate>delegate;

-(void)showWithThingsToSell:(NSDictionary*)shopInformation;

@end
