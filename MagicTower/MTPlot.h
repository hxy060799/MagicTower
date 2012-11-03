//
//  MTPlot.h
//  MagicTower
//
//  Created by Bill on 12-11-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//剧情

@interface MTPlot : NSObject{
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
}

@end
