#import "cocos2d.h"

@interface GameLayer : CCLayer {
@private
  float _accelerometerVelocity;
  CCLabelTTF* _achievementLabel;
  float _actualSubwayVelocity;
  BOOL _canChangeSubwayVelocity;
  ccTime _elapsedTime;
  int _score;
  CCLabelTTF* _scoreLabel;
  CCLabelTTF* _subwayVelocityLabel;
  CCSprite* _subwayWindow;
}

+ (CCScene*)scene;

@end
