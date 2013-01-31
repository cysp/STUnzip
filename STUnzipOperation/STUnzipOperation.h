//
//  STUnzipOperation.h
//  STUnzipOperation
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STUnzipOperation : NSOperation

- (id)initWithSourceFilePath:(NSString *)sourceFilePath destinationPath:(NSString *)destinationPath;

@end
