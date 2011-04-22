#import <Foundation/Foundation.h>

@protocol HBKeyValueObserverDelegate;

@interface HBKeyValueObserver : NSObject {
}

@property (assign) id<HBKeyValueObserverDelegate> delegate;

- (id) initWithObservee: (NSObject *) observee
			 andKeyPath: (NSString *) keyPath;

- (void) observeWithOptions: (NSKeyValueObservingOptions) options;
- (void) stopObserving;

@end

@protocol HBKeyValueObserverDelegate

- (void) keyValueObserver: (HBKeyValueObserver *) observer 
		observedChangeFor: (NSObject *) observee
			   forKeyPath: (NSString *) keyPath
			   withChange: (NSDictionary *)change;
	
@end

