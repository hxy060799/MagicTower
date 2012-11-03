//
//  DialogLayer.m
//  MagicTower
//
//  Created by Bill on 12-11-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DialogLayer.h"

@interface DialogLayer(){
    CCSprite *backgroundSprite;
    
    CCLabelTTF *dialogLabel;
    
    NSArray *dialogArray;
    
    int currentSentenceIndex;
    
    NSArray *thingsToGive;
    
    NSString *extraInf;
}

@end

@implementation DialogLayer

@synthesize delegate;

-(id)init{
    if(self=[super init]){
        currentSentenceIndex=0;
        
        backgroundSprite=[CCSprite spriteWithFile:@"dialogBackground.png"];
        backgroundSprite.anchorPoint=ccp(0,0);
        backgroundSprite.position=ccp(0,0);
        [self addChild:backgroundSprite];
        
        dialogLabel=[CCLabelTTF labelWithString:@"Text" dimensions:CGSizeMake(140, 54) hAlignment:UITextAlignmentLeft lineBreakMode:UILineBreakModeWordWrap fontName:@"Marker Felt" fontSize:12];
        dialogLabel.anchorPoint=ccp(0.5,0.5);
        dialogLabel.position=ccp(150/2+2,50/2-6);
        [self addChild:dialogLabel];
    }
    return self;
}

-(void)showWithDialogInformation:(NSDictionary*)dialogInformation{
    dialogArray=[[NSArray alloc]initWithArray:[dialogInformation objectForKey:@"Dialog"]];
    thingsToGive=[[NSArray alloc]initWithArray:[dialogInformation objectForKey:@"ThingsToGive"]];
    extraInf=[[NSString alloc]initWithString:[dialogInformation objectForKey:@"ExtraInf"]];
    [self showALine];
}

-(void)showALine{
    NSString *stringToSet=[dialogArray objectAtIndex:currentSentenceIndex];
    stringToSet=[stringToSet stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    [dialogLabel setString:stringToSet];
}

-(void)onEnter
{
	[[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(void)onExit
{
	[[[CCDirector sharedDirector]touchDispatcher] removeDelegate:self];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if(currentSentenceIndex<dialogArray.count-1){
        currentSentenceIndex++;
        [self showALine];
    }else{
        [dialogArray release];
        if(delegate)[delegate dialogEndWithThingsToGive:thingsToGive Layer:self ExtraInformation:extraInf];
    }
    return YES;
}

@end
