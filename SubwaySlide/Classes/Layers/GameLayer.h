#import "cocos2d.h"

@class Player;

@interface GameLayer : CCLayer {
@private
  Player* _player;
  float _playerRotationVelocity;
}

+ (CCScene*)scene;

@end
