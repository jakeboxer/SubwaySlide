#import "cocos2d.h"

@interface Player : NSObject {
@private
  CCSprite* _sprite;
}

@property (nonatomic, retain) CCSprite* sprite;

@end
