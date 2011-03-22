@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
@private
	RootViewController* _viewController;
	UIWindow* _window;
}

@property (nonatomic, retain) UIWindow* window;

@end
