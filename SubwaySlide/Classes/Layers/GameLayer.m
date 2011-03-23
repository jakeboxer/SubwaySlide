#import "GameLayer.h"
#import "LossLayer.h"

static float const kEpicSaveThreshold = 70.0f;

@interface GameLayer ()

@property (nonatomic, assign) float accelerometerVelocity;
@property (nonatomic, assign) CCLabelTTF* achievementLabel;
@property (nonatomic, assign) float actualSubwayVelocity;
@property (nonatomic, assign) BOOL canChangeSubwayVelocity;
@property (nonatomic, assign) float elapsedTime;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) CCLabelTTF* scoreLabel;
@property (nonatomic, assign) CCLabelTTF* subwayVelocityLabel;
@property (nonatomic, assign) CCSprite* subwayWindow;

- (void)allowChangingSubwayVelocity;
- (void)changeSubwayVelocityTo:(NSNumber*)newVelocity;
- (void)considerChangingSubwayVelocity:(ccTime)dt;
- (NSString*)currentScoreString;
- (void)update:(ccTime)dt;

@end

@implementation GameLayer

@synthesize accelerometerVelocity = _accelerometerVelocity;
@synthesize achievementLabel = _achievementLabel;
@synthesize actualSubwayVelocity = _actualSubwayVelocity;
@synthesize canChangeSubwayVelocity = _canChangeSubwayVelocity;
@synthesize elapsedTime = _elapsedTime;
@synthesize score = _score;
@synthesize scoreLabel = _scoreLabel;
@synthesize subwayVelocityLabel = _subwayVelocityLabel;
@synthesize subwayWindow = _subwayWindow;

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

    // Background
    CCSprite* background = [CCSprite spriteWithFile:@"bg_subway.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    [self addChild:background z:-1];

    // Window
    self.subwayWindow = [CCSprite spriteWithFile:@"bg_window.png" rect:CGRectMake(0, 0, 500, 193)];
    self.subwayWindow.position = ccp(25 + self.subwayWindow.contentSize.width * 0.5,
                                     242 + self.subwayWindow.contentSize.height * 0.5);
    [self addChild:self.subwayWindow];

    // Achievement label
    self.achievementLabel = [CCLabelTTF labelWithString:@""
                                               fontName:@"Helvetica-Bold"
                                               fontSize:36];
    self.achievementLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    self.achievementLabel.color = ccc3(0, 255, 0);
    self.achievementLabel.opacity = 0;
    [self addChild:self.achievementLabel];
    
    // Score label
    self.scoreLabel = [CCLabelTTF labelWithString:[self currentScoreString]
                                         fontName:@"Helvetica"
                                         fontSize:20];
    self.scoreLabel.position = ccp(winSize.width - 20, 20);
    self.scoreLabel.anchorPoint = ccp(1, 0.5);
    [self addChild:self.scoreLabel];

    // Subway velocity change label
    self.subwayVelocityLabel = [CCLabelTTF labelWithString:@""
                                                  fontName:@"Helvetica"
                                                  fontSize:24];
    self.subwayVelocityLabel.position = ccp(winSize.width * 0.5,
                                            winSize.height - (10 + self.subwayVelocityLabel.contentSize.height / 2));
    [self addChild:self.subwayVelocityLabel];

    [self scheduleUpdate];
    [self schedule:@selector(considerChangingSubwayVelocity:) interval:1];
  }

  return self;
}

#pragma mark -
#pragma mark Scheduled Methods

- (void)considerChangingSubwayVelocity:(ccTime)dt {
  if (self.canChangeSubwayVelocity && CCRANDOM_0_1() < 0.25) {
    float newVelocity = MAX(-100, MIN(100, CCRANDOM_MINUS1_1() * 2.5));

    if (newVelocity != 0.0f) {
      self.canChangeSubwayVelocity = NO;

      if (newVelocity > self.actualSubwayVelocity) {
        [self.subwayVelocityLabel setString:@"About to speed up!"];
      } else {
        [self.subwayVelocityLabel setString:@"About to slow down!"];
      }
      
      [self performSelector:@selector(changeSubwayVelocityTo:)
                 withObject:[NSNumber numberWithFloat:newVelocity]
                 afterDelay:4];
    }
  }
}

- (void)update:(ccTime)dt {
  CGRect newTextureRect = self.subwayWindow.textureRect;

  if (newTextureRect.origin.x > 640) {
    newTextureRect.origin.x = 0;
  } else {
    newTextureRect.origin.x += (self.actualSubwayVelocity + 2.5) * dt * 60;
  }

  self.subwayWindow.textureRect = newTextureRect;

  float newRotation = self.rotation - (self.accelerometerVelocity + self.actualSubwayVelocity);

  if (fabsf(newRotation) > 90.0f) {
    [[CCDirector sharedDirector] replaceScene:[LossLayer scene]];
  } else {
    self.elapsedTime += dt;
    int newScore = (int)(self.elapsedTime * 15);

    if (newScore != self.score) {
      self.score = newScore;
      [self.scoreLabel setString:[self currentScoreString]];
    }

    if (fabsf(self.rotation) > kEpicSaveThreshold &&
        fabsf(newRotation) < kEpicSaveThreshold &&
        [self.achievementLabel numberOfRunningActions] < 1) {
      [self.achievementLabel setString:@"Epic save!!!"];
      [self.achievementLabel runAction:[CCSequence actions:
                                        [CCFadeIn actionWithDuration:0.25],
                                        [CCDelayTime actionWithDuration:2.5],
                                        [CCFadeOut actionWithDuration:0.25], nil]];
    }

    self.rotation = newRotation;
  }
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
  float newVelocity = (self.accelerometerVelocity * deceleration) + (acceleration.y * sensitivity);
  
  // We must limit the max velocity of the player sprite in both directions
  if (newVelocity > maxVelocity) {
    newVelocity = maxVelocity;
  } else if (newVelocity < -maxVelocity) {
    newVelocity = -maxVelocity;
  }
  
  self.accelerometerVelocity = newVelocity;
}
     
#pragma mark -
#pragma mark Private Methods

- (void)allowChangingSubwayVelocity {
  self.canChangeSubwayVelocity = YES;
}

- (void)changeSubwayVelocityTo:(NSNumber*)newVelocity {
  [self.subwayVelocityLabel setString:@""];
  self.actualSubwayVelocity = [newVelocity floatValue];

  [self performSelector:@selector(allowChangingSubwayVelocity)
             withObject:nil
             afterDelay:2];
}

- (NSString*)currentScoreString {
  return [NSString stringWithFormat:@"Score: %d", self.score];
}

#pragma mark -
#pragma mark CCLayer Methods

- (void)onEnter {
  [super onEnter];
  [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)onExit {
  [super onExit];
  [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
