//
//  Player.h
//  MagicTower
//
//  Created by Bill on 12-10-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cocos2d.h"

@interface Player : NSObject{
    CCSprite *sprite;
}
@property(retain,nonatomic)CCSprite *sprite;
@end
