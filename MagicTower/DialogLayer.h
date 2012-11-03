//
//  DialogLayer.h
//  MagicTower
//
//  Created by Bill on 12-11-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class DialogLayer;

@protocol DialogLayerDelegate <NSObject>
-(void)dialogEndWithThingsToGive:(NSArray*)thingsToGive Layer:(DialogLayer*)layer ExtraInformation:(NSString*)extraInf;
@end

@interface DialogLayer : CCLayer {
    id<DialogLayerDelegate>delegate;
}

@property(retain,nonatomic)id<DialogLayerDelegate>delegate;

-(void)showWithDialogInformation:(NSDictionary*)dialogInformation;

@end
