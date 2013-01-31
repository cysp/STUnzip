//
//  STUnzipper.h
//  STUnzipper
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const STUnzipperErrorDomain;
NS_ENUM(NSUInteger, STUnzipperError) {
	STUnzipperErrorUnknown,
	STUnzipperErrorOpeningFile,
	STUnzipperErrorReadingFile,
};


@class STUnzipper;


@protocol STUnzipperDelegate <NSObject>
@optional
- (BOOL)unzipper:(STUnzipper *)unzipper shouldUnzipFileWithRelativePath:(NSString *)path;
@end


@interface STUnzipper : NSObject

- (id)initWithDelegate:(id<STUnzipperDelegate>)delegate;

- (BOOL)unzipSourceFile:(NSString *)sourceFilePath withDestinationPath:(NSString *)destinationPath error:(NSError * __autoreleasing *)error;

@end
