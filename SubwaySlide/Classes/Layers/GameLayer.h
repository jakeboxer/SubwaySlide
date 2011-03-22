#import "cocos2d.h"

@class Player;

@interface GameLayer : CCLayer {
@private
  BOOL _canChangeSubwayVelocity;
  Player* _player;
  float _playerRotationVelocity;
  float _subwayVelocity;
  CCLabelTTF* _subwayVelocityLabel;
}

+ (CCScene*)scene;

@end
