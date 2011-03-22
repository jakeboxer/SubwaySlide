#import "GameLayer.h"
#import "Player.h"

@interface GameLayer ()

@property (nonatomic, retain) Player* player;

@end

@implementation GameLayer

@synthesize player = _player;

#pragma mark -
#pragma mark Creation/Removal Methods

+ (CCScene*)scene {
	CCScene* scene = [CCScene node];
	[scene addChild:[GameLayer node]];

	return scene;
}

- (id)init {
  self = [super init];

  if (nil != self) {
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    self.player = [[[Player alloc] init] autorelease];
    self.player.sprite.position = ccp(winSize.width * 0.25f,
                                      self.player.sprite.contentSize.height * 0.5);
    [self addChild:self.player.sprite];
  }

  return self;
}

- (void)dealloc {
  [_player release];

  [super dealloc];
}

@end
