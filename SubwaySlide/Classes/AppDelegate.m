#import "cocos2d.h"
#import "AppDelegate.h"
#import "GameConfig.h"
#import "GameLayer.h"
#import "RootViewController.h"

@interface AppDelegate ()

@property (nonatomic, assign) RootViewController* viewController;

- (void)removeStartupFlicker;

@end

@implementation AppDelegate

@synthesize viewController = _viewController;
@synthesize window = _window;

#pragma mark -
#pragma mark Creation/Removal Methods

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[_window release];
  
	[super dealloc];
}

#pragma mark -
#pragma mark Lifecycle Methods

- (void)applicationDidBecomeActive:(UIApplication*)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

- (void)applicationDidFinishLaunching:(UIApplication*)application {
	// Init the window
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if(![CCDirector setDirectorType:kCCDirectorTypeDisplayLink]) {
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
  }
  
	CCDirector* director = [CCDirector sharedDirector];
  
	// Init the View Controller
	self.viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	self.viewController.wantsFullScreenLayout = YES;
  
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	EAGLView* glView = [EAGLView viewWithFrame:[self.window bounds]
                                 pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
                                 depthFormat:0];						// GL_DEPTH_COMPONENT16_OES
	
	// Attach the openglView to the director
	[director setOpenGLView:glView];
	
  //	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
  //	if( ! [director enableRetinaDisplay:YES] )
  //		CCLOG(@"Retina Display Not supported");
  
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
  
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
  
	// make the OpenGLView a child of the view controller
	[self.viewController setView:glView];
  
	// make the View Controller a child of the main window
	[self.window addSubview:self.viewController.view];
  [self.window makeKeyAndVisible];
  
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
  
	// Removes the startup flicker
	[self removeStartupFlicker];
  
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene:[GameLayer scene]];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillResignActive:(UIApplication*)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  CCDirector* director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	
	[_viewController release];
	[_window release];
	
	[director end];	
}

#pragma mark -
#pragma mark Cocos2D Methods

- (void)removeStartupFlicker {
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
  
  //	CC_ENABLE_DEFAULT_GL_STATES();
  //	CCDirector *director = [CCDirector sharedDirector];
  //	CGSize size = [director winSize];
  //	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
  //	sprite.position = ccp(size.width/2, size.height/2);
  //	sprite.rotation = -90;
  //	[sprite visit];
  //	[[director openGLView] swapBuffers];
  //	CC_ENABLE_DEFAULT_GL_STATES();
  
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

@end
