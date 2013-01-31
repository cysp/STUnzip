//
//  STUnzipperTests.m
//  STUnzipperTests
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STUnzipperTests.h"

#import "STUnzipper.h"


@implementation STUnzipperTests

- (void)testInstantiation {
	STUnzipper *unzipper = [[STUnzipper alloc] initWithDelegate:nil];
	(void)unzipper;
}

- (void)testUnzip {
	NSBundle * const bundle = [NSBundle bundleForClass:[self class]];

//	NSString * const temporaryDir = NSTemporaryDirectory();
//	NSString * const uniqueFilename = [[NSProcessInfo processInfo] globallyUniqueString];
	NSString * const sourceFilename = [bundle pathForResource:@"test1" ofType:@"zip"];

//	[NSFileManager defaultManager] createDirectoryAtPath:<#(NSString *)#> withIntermediateDirectories:<#(BOOL)#> attributes:<#(NSDictionary *)#> error:<#(NSError *__autoreleasing *)#>
	STUnzipper *unzipper = [[STUnzipper alloc] initWithDelegate:nil];
	NSError *error = nil;
	BOOL success = [unzipper unzipSourceFile:sourceFilename withDestinationPath:nil error:&error];

	STAssertTrue(success, @"", nil);
	STAssertNil(error, @"", nil);
}

@end
