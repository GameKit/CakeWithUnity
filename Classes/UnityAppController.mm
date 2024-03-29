#import "UnityAppController.h"
#import "iPhone_Sensors.h"

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CADisplayLink.h>
#import <UIKit/UIKit.h>
#import <Availability.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/glext.h>

#include <mach/mach_time.h>

// MSAA_DEFAULT_SAMPLE_COUNT was moved to iPhone_GlesSupport.h
// ENABLE_INTERNAL_PROFILER and related defines were moved to iPhone_Profiler.h
// kFPS define for removed: you can use Application.targetFrameRate (30 fps by default)
// DisplayLink is the only run loop mode now - all others were removed

#include "CrashReporter.h"
#include "iPhone_Common.h"
#include "iPhone_OrientationSupport.h"
#include "iPhone_Profiler.h"
#include "iPhone_View.h"

#include "UI/Keyboard.h"
#include "UI/UnityView.h"
#include "Unity/DisplayManager.h"
#include "Unity/EAGLContextHelper.h"
#include "Unity/GlesHelper.h"

//add by guoq-s
#include "MainViewController.h"
#import "DiyCakeViewController.h"
#import "DSCustomView.h"
//add by guoq-e


// Time to process events in seconds.
#define kInputProcessingTime                    0.001

// --- Unity ------------------------------------------------------------------
//

void UnityPlayerLoop();
void UnityFinishRendering();
void UnityInitApplication(const char* appPathName);
void UnityLoadApplication();
void UnityPause(bool pause);
void UnityReloadResources();
void UnitySetAudioSessionActive(bool active);
void UnityCleanup();

void UnityGLInvalidateState();

void UnitySendLocalNotification(UILocalNotification* notification);
void UnitySendRemoteNotification(NSDictionary* notification);
void UnitySendDeviceToken(NSData* deviceToken);
void UnitySendRemoteNotificationError(NSError* error);
void UnityInputProcess();
void UnitySetInputScaleFactor(float scale);
float UnityGetInputScaleFactor();
int  UnityGetTargetFPS();

extern bool UnityUse32bitDisplayBuffer();
extern bool UnityUse24bitDepthBuffer();

int     UnityGetDesiredMSAASampleCount(int defaultSampleCount);
void    UnityGetRenderingResolution(unsigned* w, unsigned* h);

enum TargetResolution
{
	kTargetResolutionNative = 0,
	kTargetResolutionAutoPerformance = 3,
	kTargetResolutionAutoQuality = 4,
	kTargetResolution320p = 5,
	kTargetResolution640p = 6,
	kTargetResolution768p = 7
};

int UnityGetTargetResolution();
int UnityGetDeviceGeneration();
void UnityRequestRenderingResolution(unsigned w, unsigned h);

void SensorsCleanup();

bool    _ios43orNewer       = false;
bool    _ios50orNewer       = false;
bool    _ios60orNewer       = false;
bool    _ios70orNewer       = false;

bool    _supportsDiscard        = false;
bool    _supportsMSAA           = false;
bool    _supportsPackedStencil  = false;

bool    _glesContextCreated = false;
bool    _unityLevelReady    = false;
bool    _skipPresent        = false;

static DisplayConnection* _mainDisplay = 0;


// --- OpenGLES --------------------------------------------------------------------
//

CADisplayLink*          _displayLink;

// This is set to true when applicationWillResignActive gets called. It is here
// to prevent calling SetPause(false) from applicationDidBecomeActive without
// previous call to applicationWillResignActive
BOOL                    _didResignActive = NO;


static void
QueryTargetResolution(int* targetW, int* targetH)
{
	int targetRes = UnityGetTargetResolution();

	float resMult = 1.0f;
	if(targetRes == kTargetResolutionAutoPerformance)
	{
		switch(UnityGetDeviceGeneration())
		{
			case deviceiPhone4:     resMult = 0.6f;     break;
			case deviceiPad1Gen:    resMult = 0.5f;     break;

			default:                resMult = 0.75f;
		}
	}

	if(targetRes == kTargetResolutionAutoQuality)
	{
		switch(UnityGetDeviceGeneration())
		{
			case deviceiPhone4:     resMult = 0.8f;     break;
			case deviceiPad1Gen:    resMult = 0.75f;    break;

			default:                resMult = 1.0f;
		}
	}

	switch( targetRes )
	{
		case kTargetResolution320p:
			*targetW = 320;
			*targetH = 480;
			break;

		case kTargetResolution640p:
			*targetW = 640;
			*targetH = 960;
			break;

		case kTargetResolution768p:
			*targetW = 768;
			*targetH = 1024;
			break;

		default:
			*targetW = _mainDisplay->screenSize.width * resMult;
			*targetH = _mainDisplay->screenSize.height * resMult;
			break;
	}
}

void PresentMainView()
{
	if(_skipPresent || _didResignActive)
	{
		UNITY_DBG_LOG ("SKIP PresentSurface %s\n", _didResignActive ? "due to going to background":"");
		return;
	}
	UNITY_DBG_LOG ("PresentSurface:\n");
	[_mainDisplay present];
}




void PresentContext_UnityCallback(struct UnityFrameStats const* unityFrameStats)
{
	Profiler_FrameEnd();
	PresentMainView();
	Profiler_FrameUpdate(unityFrameStats);
}


int OpenEAGL_UnityCallback(UIWindow** window, int* screenWidth, int* screenHeight,  int* openglesVersion)
{
	int resW=0, resH=0;
	QueryTargetResolution(&resW, &resH);

	[_mainDisplay createContext:nil];

	*window         = UnityGetMainWindow();
	*screenWidth    = resW;
	*screenHeight   = resH;
	*openglesVersion= _mainDisplay->surface.context.API;

	[EAGLContext setCurrentContext:_mainDisplay->surface.context];

	return true;
}

int GfxInited_UnityCallback(int screenWidth, int screenHeight)
{
	InitGLES();
	_glesContextCreated = true;
	[GetAppController().unityView recreateGLESSurface];

	_mainDisplay->surface.allowScreenshot = true;

	SetupUnityDefaultFBO(&_mainDisplay->surface);
	glViewport(0, 0, _mainDisplay->surface.targetW, _mainDisplay->surface.targetH);

	return true;
}

void NotifyFramerateChange(int targetFPS)
{
	if( targetFPS <= 0 )
		targetFPS = 60;

	int animationFrameInterval = (60.0 / (targetFPS));
	if (animationFrameInterval < 1)
		animationFrameInterval = 1;

	[_displayLink setFrameInterval:animationFrameInterval];
}

void LogToNSLogHandler(LogType logType, const char* log, va_list list)
{
	NSLogv([NSString stringWithUTF8String:log], list);
}

void UnityInitTrampoline()
{
#if ENABLE_CRASH_REPORT_SUBMISSION
	SubmitCrashReportsAsync();
#endif
#if ENABLE_CUSTOM_CRASH_REPORTER
	InitCrashReporter();
#endif

	_ios43orNewer = [[[UIDevice currentDevice] systemVersion] compare: @"4.3" options: NSNumericSearch] != NSOrderedAscending;
	_ios50orNewer = [[[UIDevice currentDevice] systemVersion] compare: @"5.0" options: NSNumericSearch] != NSOrderedAscending;
	_ios60orNewer = [[[UIDevice currentDevice] systemVersion] compare: @"6.0" options: NSNumericSearch] != NSOrderedAscending;
	_ios70orNewer = [[[UIDevice currentDevice] systemVersion] compare: @"7.0" options: NSNumericSearch] != NSOrderedAscending;

	// Try writing to console and if it fails switch to NSLog logging
	fprintf(stdout, "\n");
	if (ftell(stdout) < 0)
		SetLogEntryHandler(LogToNSLogHandler);
}


// --- AppController --------------------------------------------------------------------
//


@implementation UnityAppController

@synthesize unityView			= _unityView;
@synthesize rootView			= _rootView;
@synthesize rootViewController	= _rootController;
@synthesize window = _window;

// mod by icylydia
// add CoreData Support
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CakeDIY" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CakeDIY.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CoreDataGenerator" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, couldn't copy preloaded data");
        }
    }
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#pragma mark -

- (void)repaintDisplayLink
{
	[_displayLink setPaused: YES];
	{
		static const CFStringRef kTrackingRunLoopMode = CFStringRef(UITrackingRunLoopMode);
		while (CFRunLoopRunInMode(kTrackingRunLoopMode, kInputProcessingTime, TRUE) == kCFRunLoopRunHandledSource)
			;
	}
	[_displayLink setPaused: NO];

	if(_didResignActive)
		return;

	SetupUnityDefaultFBO(&_mainDisplay->surface);

	CheckOrientationRequest();
	[GetAppController().unityView recreateGLESSurfaceIfNeeded];

	Profiler_FrameStart();
	UnityInputProcess();
	UnityPlayerLoop();

	[[DisplayManager Instance] presentAllButMain];

	SetupUnityDefaultFBO(&_mainDisplay->surface);
}

- (void)startUnity:(UIApplication*)application
{
	char const* appPath = [[[NSBundle mainBundle] bundlePath]UTF8String];
	UnityInitApplication(appPath);

	[[DisplayManager Instance] updateDisplayListInUnity];

	OnUnityInited();
	UnitySetInputScaleFactor([UIScreen mainScreen].scale);

	UnityLoadApplication();
	Profiler_InitProfiler();

	_unityLevelReady = true;
	OnUnityReady();

	// Frame interval defines how many display frames must pass between each time the display link fires.
	int animationFrameInterval = 60.0 / (float)UnityGetTargetFPS();
	assert(animationFrameInterval >= 1);

	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(repaintDisplayLink)];
	[_displayLink setFrameInterval:animationFrameInterval];
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (UnityView*)initUnityViewImpl
{
	return [[UnityView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}
- (UnityView*)initUnityView
{
	_unityView = [self initUnityViewImpl];
    
    // mod by icylydia
    // add background image
//    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
//    [background setImage:[UIImage imageNamed:@"background.png"]];
//    [_unityView addSubview:background];
//    _unityView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    // mod end
    
    
	_unityView.contentScaleFactor = [UIScreen mainScreen].scale;
	_unityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	return _unityView;
}

- (void)createViewHierarchyImpl
{
	_rootView = _unityView;
	_rootController = [[UnityDefaultViewController alloc] init];
}

- (void)createViewHierarchy
{
	[self createViewHierarchyImpl];
	NSAssert(_rootView != nil, @"createViewHierarchyImpl must assign _rootView");
	NSAssert(_rootController != nil, @"createViewHierarchyImpl must assign _rootController");

	_rootView.contentScaleFactor = [UIScreen mainScreen].scale;
	_rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	_rootController.wantsFullScreenLayout = TRUE;
	_rootController.view = _rootView;
	if([_rootController isKindOfClass: [UnityViewControllerBase class]])
		[(UnityViewControllerBase*)_rootController assignUnityView:_unityView];
}

- (void)showGameUI:(UIWindow*)window
{
	[window addSubview: _rootView];
	window.rootViewController = _rootController;
	[window bringSubviewToFront: _rootView];
}

- (void)onForcedOrientation:(ScreenOrientation)orient
{
	[_unityView willRotateTo:orient];
	OrientView(_rootView, orient);
	[_rootView layoutSubviews];
	[_unityView didRotate];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	// UIInterfaceOrientationMaskAll
	// it is the safest way of doing it:
	// - GameCenter and some other services might have portrait-only variant
	//     and will throw exception if portrait is not supported here
	// - When you change allowed orientations if you end up forbidding current one
	//     exception will be thrown
	// Anyway this is intersected with values provided from UIViewController, so we are good
	return   (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
		   | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
//    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
	UnitySendLocalNotification(notification);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	UnitySendRemoteNotification(userInfo);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	UnitySendDeviceToken(deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	UnitySendRemoteNotificationError(error);
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	printf_console("-> applicationDidFinishLaunching()\n");
	// get local notification
	if (&UIApplicationLaunchOptionsLocalNotificationKey != nil)
	{
		UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
		if (notification)
			UnitySendLocalNotification(notification);
		}

	// get remote notification
	if (&UIApplicationLaunchOptionsRemoteNotificationKey != nil)
	{
		NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (notification)
			UnitySendRemoteNotification(notification);
		}

	if ([UIDevice currentDevice].generatesDeviceOrientationNotifications == NO)
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

	//del by guoq-s
	/*
	[DisplayManager Initialize];
	_mainDisplay = [[DisplayManager Instance] mainDisplay];
	[_mainDisplay createView:YES showRightAway:NO];

	[KeyboardDelegate Initialize];
	CreateViewHierarchy();

	[self performSelector:@selector(startUnity:) withObject:application afterDelay:0];
 	*/
	//del by guoq-e
//add by guoq-s
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//	_mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
//	_window.rootViewController = _mvc;

    
    // mod by icylydia
    // write CoreData
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CoreDataInited"]) {
        
        [userDefaults setBool:YES forKey:@"CoreDataInited"];
    }
    LCYMainViewController *mainVC = [[LCYMainViewController alloc] init];
    _icyMainVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [_icyMainVC setNavigationBarHidden:YES];
    _window.rootViewController = _icyMainVC;
	[_window makeKeyAndVisible];

	return NO;
}

//add by guoq-s
- (void) dsStartUnity
{
	if(_unityView  == NULL) {
		[DisplayManager Initialize];
		
		_mainDisplay = [[DisplayManager Instance] mainDisplay];
		[_mainDisplay createView:YES showRightAway:NO];
		
		[_mainDisplay setWindow:_window];
		
		[KeyboardDelegate Initialize];
		CreateViewHierarchy();
		
		//NSString* orientation = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIInterfaceOrientation"];
		

		[self performSelector:@selector(startUnity:) withObject:[UIApplication sharedApplication] afterDelay:0];
        
 
	}
	else {

		_window.rootViewController = _rootController;

        
        
        [[[UnityGetMainWindow() rootViewController] view] setHidden:NO];
        [self addCakeView];
		if (_didResignActive) {
			UnityPause(false);
        }
		_didResignActive = NO;
	}
}

//add by guoq-e

// For iOS 4
// Callback order:
//   applicationDidResignActive()
//   applicationDidEnterBackground()
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	printf_console("-> applicationDidEnterBackground()\n");
}

// For iOS 4
// Callback order:
//   applicationWillEnterForeground()
//   applicationDidBecomeActive()
- (void)applicationWillEnterForeground:(UIApplication *)application
{
	printf_console("-> applicationWillEnterForeground()\n");
	// if we were showing video before going to background - the view size may be changed while we are in background
	[GetAppController().unityView recreateGLESSurfaceIfNeeded];
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
	printf_console("-> applicationDidBecomeActive()\n");
	if (_didResignActive)
		UnityPause(false);

	_didResignActive = NO;
}

- (void)applicationWillResignActive:(UIApplication*)application
{
	printf_console("-> applicationWillResignActive()\n");
	UnityPause(true);

	extern void UnityStopVideoIfPlaying();
	UnityStopVideoIfPlaying();

	_didResignActive = YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
	printf_console("WARNING -> applicationDidReceiveMemoryWarning()\n");
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	printf_console("-> applicationWillTerminate()\n");

	Profiler_UninitProfiler();

	UnityCleanup();
}

- (void)dealloc
{
	SensorsCleanup();
	ReleaseViewHierarchy();
	[super dealloc];
}
//add by guoq-s
- (void) backToMain
{
    [[[UnityGetMainWindow() rootViewController] view] setHidden:YES];

//	_window.rootViewController = _mvc;
    _window.rootViewController = _icyMainVC;
    
	[_window makeKeyAndVisible];
    //[_rootController dismissModalViewControllerAnimated:YES];
    [_rootController dismissViewControllerAnimated:YES completion:nil];
}

- (void) addCakeView
{
    DiyCakeViewController *diyCakeViewController = [[DiyCakeViewController alloc] initWithNibName:@"DiyCakeViewController" bundle:nil];
    
    [_rootController.view addSubview:diyCakeViewController.view];
   
}
//add by guoq-e
@end


extern "C" {
    void _BackToMain()
    {
        UnityPause(true);
        _didResignActive = YES;
        Profiler_UninitProfiler();
		// ReleaseViewHierarchy();
		// UnityCleanup();
	
		[GetAppController() backToMain];
    }
    
    void _StartCakeView()
    {
        [GetAppController() addCakeView];
    }
}