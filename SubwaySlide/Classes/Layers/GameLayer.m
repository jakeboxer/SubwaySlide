#import "GameLayer.h"

@implementation GameLayer

#pragma mark -
#pragma mark Creation/Removal Methods

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	[scene addChild:[GameLayer node]];

	return scene;
}

@end
