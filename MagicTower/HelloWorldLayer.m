//
//  HelloWorldLayer.m
//  MagicTower
//
//  Created by Bill on 12-10-12.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		CCSprite *backgroundSprite=[[CCSprite alloc]initWithFile:@"gameBackground.png"];
        backgroundSprite.anchorPoint=ccp(0,0);
        [self addChild:backgroundSprite];
        [backgroundSprite release];
        
        NSMutableArray *mapToUse=[self readPlist];
        NSLog(@"%@",mapToUse);
        
        for(int i=0;i<11;i++){
            for(int j=0;j<11;j++){
                int thisBlock=[[[mapToUse objectAtIndex:i]objectAtIndex:j]intValue];
                CCSprite *mapBlockSprite=nil;
                switch(thisBlock){
                    case 0:
                        break;
                    case 1:
                        mapBlockSprite=[[CCSprite alloc]initWithFile:@"map_wall.png"];
                        break;
                    case 2:
                        mapBlockSprite=[[CCSprite alloc]initWithFile:@"map_radSea.png"];
                        break;
                    case 3:
                        mapBlockSprite=[[CCSprite alloc]initWithFile:@"map_air.png"];
                        break;                   
                    case 4:
                        mapBlockSprite=[[CCSprite alloc]initWithFile:@"map_upstairs.png"];
                        break;
                    default:
                        break;
                }
                if(mapBlockSprite){
                    mapBlockSprite.anchorPoint=ccp(0,0);
                    mapBlockSprite.position=ccp(103+25*j,23+25*i);
                    [self addChild:mapBlockSprite];
                    [mapBlockSprite release];
                }
                
            }
        }
	}
	return self;
}

-(NSMutableArray*)readPlist{
    NSString *error=nil;
    NSPropertyListFormat format;
    NSMutableDictionary *dict=nil;
    NSString *filePath=[[NSBundle mainBundle] pathForResource:@"MapInformation" ofType:@"plist"];
    NSData *plistXML=[[NSFileManager defaultManager]contentsAtPath:filePath];
    dict=(NSMutableDictionary*)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error];
    NSLog(@"%@",dict);
    return [dict objectForKey:@"BeforeStart"];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
