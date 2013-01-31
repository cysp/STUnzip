//
//  STUnzipOperation.m
//  STUnzipOperation
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STUnzipOperation.h"
#import "STUnzipper.h"


@interface STUnzipOperation () <STUnzipperDelegate>
@property (nonatomic,copy,readonly) NSString *sourceFilePath;
@property (nonatomic,copy,readonly) NSString *destinationPath;

@property (nonatomic,assign,getter=isExecuting) BOOL executing;
@property (nonatomic,assign,getter=isFinished) BOOL finished;
@end


@implementation STUnzipOperation

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithSourceFilePath:(NSString *)sourceFilePath destinationPath:(NSString *)destinationPath {
	if ((self = [super init])) {
		_sourceFilePath = [sourceFilePath copy];
		_destinationPath = [destinationPath copy];
	}
	return self;
}

- (BOOL)isConcurrent {
	return YES;
}

- (void)start {
	if ([self isCancelled]) {
		[self setFinished:YES];
		return;
	}

	[self setExecuting:YES];

	STUnzipper * const unzipper = [[STUnzipper alloc] initWithDelegate:self];

	NSError *error = nil;
	if (![unzipper unzipSourceFile:self.sourceFilePath withDestinationPath:self.destinationPath error:&error]) {
		NSLog(@"%@ error: %@", NSStringFromClass(self.class), error);
		[self setExecuting:NO];
		[self setFinished:YES];
		return;
	}

	[self setExecuting:NO];
	[self setFinished:YES];
}

@end
