#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import <GHUnit/GHUnit.h>
#import "HBKeyValueObserver.h"

@interface HBKeyValueObserverTestObservee : NSObject
{
}

@property (nonatomic) BOOL property;

@end

@implementation HBKeyValueObserverTestObservee

@synthesize property;

@end

@interface HBKeyValueObserverTest : GHTestCase {
	HBKeyValueObserverTestObservee *testObservee;
	NSString *testKeyPath;
	
	HBKeyValueObserver *testObject;
	
	id mockObserverDelegate;
}

@end

@implementation HBKeyValueObserverTest

- (void) setUp {
	[super setUp];

	testObservee = [[[HBKeyValueObserverTestObservee alloc] init] autorelease];
	testKeyPath = @"property";
	
	testObject = [[[HBKeyValueObserver alloc] initWithObservee:testObservee
													andKeyPath:testKeyPath] autorelease];
   	mockObserverDelegate = [OCMockObject mockForProtocol:@protocol(HBKeyValueObserverDelegate)];
	testObject.delegate = mockObserverDelegate;
}

- (void) test_If_Not_Observing_Delegate_Not_Called_On_Property_Change {
	testObservee.property = YES;
	
	[mockObserverDelegate verify];
}

- (void) test_If_Observing_Delegate_Called_On_Property_Change {
	[testObject observeWithOptions:NSKeyValueObservingOptionNew];
	
	[[mockObserverDelegate expect] keyValueObserver:testObject 
								  observedChangeFor:testObservee
										 forKeyPath:testKeyPath
										 withChange:OCMOCK_ANY];
	
	testObservee.property = YES;
	
	[mockObserverDelegate verify];
}

- (void) test_If_Stopped_Observing_Delegate_Not_Called_On_Property_Change {
	[testObject observeWithOptions:NSKeyValueObservingOptionNew];
	[testObject stopObserving];
	
	testObservee.property = YES;
	
	[mockObserverDelegate verify];
}

- (void) test_Observe_With_Options_Resets_Options_With_Second_Call {
	[testObject observeWithOptions:NSKeyValueObservingOptionNew];
	
	// due to NSKeyValueObservingOptionInitial
	[[mockObserverDelegate expect] keyValueObserver:testObject 
								  observedChangeFor:testObservee
										 forKeyPath:testKeyPath
										 withChange:OCMOCK_ANY];
	
	[testObject observeWithOptions:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial];
	
	// due to NSKeyValueObservingOptionNew
	
	[[mockObserverDelegate expect] keyValueObserver:testObject 
								  observedChangeFor:testObservee
										 forKeyPath:testKeyPath
										 withChange:OCMOCK_ANY];
	
	testObservee.property = YES;
	
	[mockObserverDelegate verify];
}


// Trying to make sure that creation and deletion works.  Trying to induce a crash.
// This test should run first so that it might cause a crash in other tests if something is bad
- (void) test_1_Many_KeyValueObservers_Can_Be_Created_And_Destroyed {
	for (int i=0; i < 1000; i++) {
		testObservee = [[HBKeyValueObserverTestObservee alloc] init];
		testObject = [[HBKeyValueObserver alloc] initWithObservee:testObservee 
													   andKeyPath:testKeyPath];
		[testObject observeWithOptions:NSKeyValueObservingOptionNew];
		[testObject release];
		[testObservee release];
	}
}

@end
