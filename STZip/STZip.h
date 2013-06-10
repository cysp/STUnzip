//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot

#import <Foundation/Foundation.h>


extern NSString * const STZipErrorDomain;
NS_ENUM(NSUInteger, STZipError) {
	STZipErrorUnknown,
	STZipErrorOpeningFile,
	STZipErrorReadingFile,
};


@interface STZip : NSObject

- (id)initWithPath:(NSString *)path;

- (NSUInteger)numberOfFiles;
- (NSSet *)filenames;
- (NSSet *)filenamesWithError:(NSError * __autoreleasing *)error;

- (NSData *)dataWithContentsOfFileAtPath:(NSString *)path;
- (NSData *)dataWithContentsOfFileAtPath:(NSString *)path error:(NSError * __autoreleasing *)error;

@end
