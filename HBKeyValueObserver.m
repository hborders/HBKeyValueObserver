#import "HBKeyValueObserver.h"


@interface HBKeyValueObserver()

@property (nonatomic, retain) NSObject *observee;
@property (nonatomic, retain) NSString *keyPath;
@property (nonatomic, retain) NSObject *monitor;

@property BOOL observing;

@end


@implementation HBKeyValueObserver

@synthesize observee = _observee;
@synthesize keyPath = _keyPath;
@synthesize monitor = _monitor;
@synthesize observing = _observing;
@synthesize delegate = _delegate;

- (id) initWithObservee: (NSObject *) observee
			 andKeyPath: (NSString *) keyPath {
	if (self = [super init]) {
		self.observee = observee;
		self.keyPath = keyPath;
		self.monitor = [[[NSObject alloc] init] autorelease];
		self.observing = NO;
	}
	
	return self;
}

- (void) dealloc {
	[self stopObserving];
	
	self.observee = nil;
	self.keyPath = nil;
	self.monitor = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark public API

- (void) observeWithOptions: (NSKeyValueObservingOptions) options {
	@synchronized(self.monitor) {
		if (self.observing) {
			[self stopObserving];
		} 
		self.observing = YES;
		[self.observee addObserver:self 
						forKeyPath:self.keyPath 
						   options:options 
						   context:self.monitor];
	}
}

- (void) stopObserving {
	@synchronized(self.monitor) {
		if (self.observing) {
			[self.observee removeObserver:self
							   forKeyPath:self.keyPath];
			self.observing = NO;	
		}
	}
}

#pragma mark -
#pragma mark NSKeyValueObserving

- (void) observeValueForKeyPath:(NSString *)keyPath 
					   ofObject:(id)object 
						 change:(NSDictionary *)change 
						context:(void *)context {
	if (self.monitor == context) {
		[self.delegate keyValueObserver:self 
					  observedChangeFor:object
							 forKeyPath:keyPath
							 withChange:change];
	} else {
		[super observeValueForKeyPath: keyPath
							 ofObject: object
							   change: change
							  context: context];
	}
}

@end
