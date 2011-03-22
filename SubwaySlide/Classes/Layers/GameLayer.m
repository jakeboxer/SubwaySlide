#import "GameLayer.h"
#import "Player.h"

@interface GameLayer ()

@property (nonatomic, assign) BOOL canChangeSubwayVelocity;
@property (nonatomic, retain) Player* player;
@property (nonatomic, assign) float playerRotationVelocity;
@property (nonatomic, assign) float subwayVelocity;
@property (nonatomic, assign) CCLabelTTF* subwayVelocityLabel;

- (void)allowChangingSubwayVelocity;
- (void)changeSubwayVelocityTo:(NSNumber*)newVelocity;
- (void)considerChangingSubwayVelocity:(ccTime)dt;
- (void)update:(ccTime)dt;

@end

@implementation GameLayer

@synthesize canChangeSubwayVelocity = _canChangeSubwayVelocity;
@synthesize player = _player;
@synthesize playerRotationVelocity = _playerRotationVelocity;
@synthesize subwayVelocity = _subwayVelocity;
@synthesize subwayVelocityLabel = _subwayVelocityLabel;

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
    self.canChangeSubwayVelocity = YES;

    self.player = [[[Player alloc] init] autorelease];
    self.player.sprite.anchorPoint = ccp(0.5, 0);
    self.player.sprite.position = ccp(winSize.width * 0.25f, 0);
    [self addChild:self.player.sprite];

    self.subwayVelocityLabel = [CCLabelTTF labelWithString:@"Go!" fontName:@"Helvetica" fontSize:24];
    self.subwayVelocityLabel.position = ccp(winSize.width * 0.5,
                                            winSize.height - (self.subwayVelocityLabel.contentSize.height / 2));
    [self addChild:self.subwayVelocityLabel];

    [self scheduleUpdate];
    [self schedule:@selector(considerChangingSubwayVelocity:) interval:1];
  }

  return self;
}

- (void)dealloc {
  [_player release];

  [super dealloc];
}

#pragma mark -
#pragma mark Scheduled Methods

- (void)considerChangingSubwayVelocity:(ccTime)dt {
  if (self.canChangeSubwayVelocity && CCRANDOM_0_1() > 0.25) {
    self.canChangeSubwayVelocity = NO;
    float newVelocity = MAX(-100, MIN(100, CCRANDOM_MINUS1_1() * 2.5));

    if (newVelocity > 0) {
      [self.subwayVelocityLabel setString:@"About to speed up!"];
    } else {
      [self.subwayVelocityLabel setString:@"About to slow down!"];
    }

    [self performSelector:@selector(changeSubwayVelocityTo:)
               withObject:[NSNumber numberWithFloat:newVelocity]
               afterDelay:4];
  }
}

- (void)update:(ccTime)dt {
  float newRotation = self.player.sprite.rotation - (self.playerRotationVelocity + self.subwayVelocity);

  if (newRotation > 90.0f) {
    newRotation = 90.0f;
    self.playerRotationVelocity = 0;
    self.subwayVelocity = 0;
  } else if (newRotation < -90.0f) {
    newRotation = -90.0f;
    self.playerRotationVelocity = 0;
    self.subwayVelocity = 0;
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
     
#pragma mark -
#pragma mark Private Methods

- (void)allowChangingSubwayVelocity {
  self.canChangeSubwayVelocity = YES;
}

- (void)changeSubwayVelocityTo:(NSNumber*)newVelocity {
  self.subwayVelocity = [newVelocity floatValue];

  if (self.subwayVelocity > 0) {
    [self.subwayVelocityLabel setString:@"Speeding up!"];
  } else {
    [self.subwayVelocityLabel setString:@"Slowing down!"];
  }

  [self performSelector:@selector(allowChangingSubwayVelocity)
             withObject:nil
             afterDelay:2];
}

@end
