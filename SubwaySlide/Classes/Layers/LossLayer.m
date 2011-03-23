#import "GameLayer.h"
#import "LossLayer.h"

@implementation LossLayer

#pragma mark -
#pragma mark Creation/Removal Methods

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	[scene addChild:[LossLayer node]];
  
	return scene;
}

- (id)init {
  self = [super init];

  if (nil != self) {
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    self.isTouchEnabled = YES;

    CCSprite* background = [CCSprite spriteWithFile:@"bg_loss.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    [self addChild:background z:-1];

    CCLabelTTF* label = [CCLabelTTF labelWithString:@"Play Again"
                                           fontName:@"Helvetica"
                                           fontSize:30];

    CCMenuItemLabel* menuItem = [CCMenuItemLabel itemWithLabel:label block:^(id sender) {
      [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
    }];

    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.9);
    [self addChild:menu];
  }

  return self;
}

@end
