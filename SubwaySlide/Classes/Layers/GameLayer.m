#import "GameLayer.h"
#import "Player.h"

@interface GameLayer ()

@property (nonatomic, retain) Player* player;
@property (nonatomic, assign) float playerRotationVelocity;

- (void)update:(ccTime)dt;

@end

@implementation GameLayer

@synthesize player = _player;
@synthesize playerRotationVelocity = _playerRotationVelocity;

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

    self.isAccelerometerEnabled = YES;

    self.player = [[[Player alloc] init] autorelease];
    self.player.sprite.anchorPoint = ccp(0.5, 0);
    self.player.sprite.position = ccp(winSize.width * 0.25f, 0);
    [self addChild:self.player.sprite];

    [self scheduleUpdate];
  }

  return self;
}

- (void)dealloc {
  [_player release];

  [super dealloc];
}

#pragma mark -
#pragma mark Scheduled Methods

- (void)update:(ccTime)dt {
  float newRotation = self.player.sprite.rotation - self.playerRotationVelocity;

  if (newRotation > 90.0f) {
    newRotation = 90.0f;
    self.playerRotationVelocity = 0;
  } else if (newRotation < -90.0f) {
    newRotation = -90.0f;
    self.playerRotationVelocity = 0;
  }

  self.player.sprite.rotation = newRotation;
}

#pragma mark -
#pragma mark User Input Methods

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
  // Controls how quickly velocity decelerates (lower = quicker to change direction)
  float deceleration = 0.4f;
  
  // Determines how sensitive the accelerometer reacts (higher = more sensitive)
  float sensitivity = 6.0f;
  
  // How fast the velocity can be at most
  float maxVelocity = 100;
  
  // Adjust velocity based on current accelerometer acceleration
  float newVelocity = (self.playerRotationVelocity * deceleration) + (acceleration.y * sensitivity);
  
  // We must limit the max velocity of the player sprite in both directions
  if (newVelocity > maxVelocity) {
    newVelocity = maxVelocity;
  } else if (newVelocity < -maxVelocity) {
    newVelocity = -maxVelocity;
  }
  
  self.playerRotationVelocity = newVelocity;
}

@end
