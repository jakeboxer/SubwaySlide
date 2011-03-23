#import "cocos2d.h"

@interface GameLayer : CCLayer {
@private
  float _accelerometerVelocity;
  float _actualSubwayVelocity;
  BOOL _canChangeSubwayVelocity;
  CCLabelTTF* _subwayVelocityLabel;
  CCSprite* _subwayWindow;
}

+ (CCScene*)scene;

@end
