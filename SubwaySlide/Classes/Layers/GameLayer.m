#import "GameLayer.h"
#import "LossLayer.h"

@interface GameLayer ()

@property (nonatomic, assign) float accelerometerVelocity;
@property (nonatomic, assign) float actualSubwayVelocity;
@property (nonatomic, assign) BOOL canChangeSubwayVelocity;
@property (nonatomic, assign) float modifyingSubwayVelocity;
@property (nonatomic, assign) CCLabelTTF* subwayVelocityLabel;
@property (nonatomic, assign) CCSprite* subwayWindow;

- (void)allowChangingSubwayVelocity;
- (void)changeSubwayVelocityTo:(NSNumber*)newVelocity;
- (void)considerChangingSubwayVelocity:(ccTime)dt;
- (void)update:(ccTime)dt;

@end

@implementation GameLayer

@synthesize accelerometerVelocity = _accelerometerVelocity;
@synthesize actualSubwayVelocity = _actualSubwayVelocity;
@synthesize canChangeSubwayVelocity = _canChangeSubwayVelocity;
@synthesize modifyingSubwayVelocity = _modifyingSubwayVelocity;
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

    self.subwayVelocityLabel = [CCLabelTTF labelWithString:@"Go!" fontName:@"Helvetica" fontSize:24];
    self.subwayVelocityLabel.position = ccp(winSize.width * 0.5,
                                            winSize.height - (self.subwayVelocityLabel.contentSize.height / 2));
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

  if (self.modifyingSubwayVelocity != 0.0f) {
    float newModifyingSubwayVelocity = self.modifyingSubwayVelocity;

    // If the subway is adding velocity, decrease it.
    if (newModifyingSubwayVelocity > 0.0f) {
      newModifyingSubwayVelocity -= dt;
    } else {
      newModifyingSubwayVelocity += dt;
    }

    // If the subway velocity changed signs, set it to 0 and allow changes in
    // 2 seconds
    if ((self.modifyingSubwayVelocity > 0.0f && newModifyingSubwayVelocity <= 0.0f) ||
        (self.modifyingSubwayVelocity < 0.0f && newModifyingSubwayVelocity >= 0.0f)){
      newModifyingSubwayVelocity = 0;
      [self performSelector:@selector(allowChangingSubwayVelocity)
                 withObject:nil
                 afterDelay:2];
    }

    self.modifyingSubwayVelocity = newModifyingSubwayVelocity;
  }

  self.subwayWindow.textureRect = newTextureRect;

  float newRotation = self.rotation - (self.accelerometerVelocity + self.modifyingSubwayVelocity);

  if (fabsf(newRotation) > 90.0f) {
    [[CCDirector sharedDirector] replaceScene:[LossLayer scene]];
  } else {
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
  self.modifyingSubwayVelocity = self.actualSubwayVelocity;
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
