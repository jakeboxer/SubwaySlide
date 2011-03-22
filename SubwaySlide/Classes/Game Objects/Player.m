#import "Player.h"

@implementation Player

@synthesize sprite = _sprite;

#pragma mark -
#pragma mark Creation/Removal Methods

- (id)init {
  self = [super init];

  if (nil != self) {
    self.sprite = [CCSprite spriteWithFile:@"player.png"];
  }

  return self;
}

- (void)dealloc {
  [_sprite release];

  [super dealloc];
}

@end
