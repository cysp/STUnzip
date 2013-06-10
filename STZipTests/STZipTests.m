//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STZipTests.h"

#import "STZip.h"


@implementation STZipTests

- (void)testInstantiation {
	{
		STZip *zip;
		STAssertThrows(zip = [[STZip alloc] initWithPath:nil], @"");
		STAssertNil(zip, @"");
	}

	{
		STZip *zip = [[STZip alloc] initWithPath:@"foo.zip"];
		STAssertNil(zip, @"");
	}

	{
		NSBundle * const bundle = [NSBundle bundleForClass:[self class]];
		NSString * const path = [bundle pathForResource:@"test1" ofType:@"zip"];
		STAssertNotNil(path, @"");
		if (path) {
			STZip *zip = [[STZip alloc] initWithPath:path];
			STAssertNotNil(zip, @"");
		}
	}
}

- (void)testListing {
	NSBundle * const bundle = [NSBundle bundleForClass:[self class]];
	NSString * const path = [bundle pathForResource:@"test1" ofType:@"zip"];
	STAssertNotNil(path, @"");
	if (!path) {
		return;
	}

	NSSet *expectedFilenames = [NSSet setWithObjects:@"a", @"b", @"c/c", nil];

	STZip *zip = [[STZip alloc] initWithPath:path];
	STAssertNotNil(zip, @"");

	NSSet *zipFilenames = [zip filenames];
	STAssertNotNil(zipFilenames, @"");
	STAssertEquals([zipFilenames count], 3U, @"");

	STAssertEqualObjects(zipFilenames, expectedFilenames, @"");
}

- (void)testFiledata {
	NSBundle * const bundle = [NSBundle bundleForClass:[self class]];
	NSString * const path = [bundle pathForResource:@"test1" ofType:@"zip"];
	STAssertNotNil(path, @"");
	if (!path) {
		return;
	}

	NSData *expectedDataA = [@"" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *expectedDataB = [@"b" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *expectedDataC = [@"c" dataUsingEncoding:NSUTF8StringEncoding];

	STZip *zip = [[STZip alloc] initWithPath:path];
	STAssertNotNil(zip, @"");

	NSData *zipFiledataA = [zip dataWithContentsOfFileAtPath:@"a"];
	NSData *zipFiledataB = [zip dataWithContentsOfFileAtPath:@"b"];
	NSData *zipFiledataC = [zip dataWithContentsOfFileAtPath:@"c/c"];

	STAssertEqualObjects(zipFiledataA, expectedDataA, @"");
	STAssertEqualObjects(zipFiledataB, expectedDataB, @"");
	STAssertEqualObjects(zipFiledataC, expectedDataC, @"");
}

@end
