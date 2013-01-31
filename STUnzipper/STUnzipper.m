//
//  STUnzipper.m
//  STUnzipper
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STUnzipper.h"

#import "unzip.h"


NSString * const STUnzipperErrorDomain = @"STUnzipper";


@interface STUnzipper ()
@property (nonatomic,weak,readonly) id<STUnzipperDelegate> delegate;
@end


@implementation STUnzipper

- (id)init {
	return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<STUnzipperDelegate>)delegate {
	if ((self = [super init])) {
		_delegate = delegate;
	}
	return self;
}


@synthesize delegate = _delegate;


- (BOOL)unzipSourceFile:(NSString *)sourceFilePath withDestinationPath:(NSString *)destinationPath error:(NSError * __autoreleasing *)error {
	id<STUnzipperDelegate> const delegate = self.delegate;
	BOOL const delegateHasShouldUnzipFileWithPath = [delegate respondsToSelector:@selector(unzipper:shouldUnzipFileWithRelativePath:)];

	unzFile uf = unzOpen64([sourceFilePath fileSystemRepresentation]);
	if (!uf) {
		if (error) {
			*error = [NSError errorWithDomain:STUnzipperErrorDomain code:STUnzipperErrorOpeningFile userInfo:nil];
		}
		return NO;
	}

	BOOL success = YES;

	{
		unz_file_info64 uf_finfo;
		uLong const uf_filename_buf_size = 256;
		char uf_filename_buf[uf_filename_buf_size];
		int err = unzGoToFirstFile2(uf, &uf_finfo, uf_filename_buf, uf_filename_buf_size, NULL, 0, NULL, 0);
		while (err == UNZ_OK) {
			NSString *filename = nil;
			if (uf_finfo.size_filename < uf_filename_buf_size) {
				filename = [[NSString alloc] initWithBytesNoCopy:uf_filename_buf length:uf_finfo.size_filename encoding:NSUTF8StringEncoding freeWhenDone:NO];
			} else {
				unsigned long uf_filename_alloc_size = uf_finfo.size_filename + 1;
				char *uf_filename_alloc = calloc(uf_filename_alloc_size, 1);
				unzGetCurrentFileInfo(uf, NULL, uf_filename_alloc, uf_filename_alloc_size, NULL, 0, NULL, 0);
				filename = [[NSString alloc] initWithBytesNoCopy:uf_filename_alloc length:uf_filename_alloc_size - 1 encoding:NSUTF8StringEncoding freeWhenDone:YES];
			}


			BOOL shouldUnzipFile = YES;
			if (delegateHasShouldUnzipFileWithPath) {
				shouldUnzipFile = [delegate unzipper:self shouldUnzipFileWithRelativePath:filename];
			}

			if (shouldUnzipFile) {
				int ferr = unzOpenCurrentFile(uf);
				if (ferr != UNZ_OK) {
					if (error) {
						*error = [NSError errorWithDomain:STUnzipperErrorDomain code:STUnzipperErrorReadingFile userInfo:@{ @"minizipError": @(ferr) }];
					}
					success = NO;
					unzCloseCurrentFile(uf);
					break;
				}

				const unsigned int filedatabuf_len = 512;
				char filedatabuf[filedatabuf_len];

				NSString * const destinationFilePath = [destinationPath stringByAppendingPathComponent:filename];
				NSFileHandle * const fileHandle = [NSFileHandle fileHandleForWritingAtPath:destinationFilePath];
				if (!fileHandle) {
					success = NO;
					break;
				}

				int nread = 0;
				do {
					nread = unzReadCurrentFile(uf, filedatabuf, filedatabuf_len);
					if (nread > 0) {
						NSData *chunk = [[NSData alloc] initWithBytesNoCopy:filedatabuf length:(NSUInteger)nread freeWhenDone:NO];
						[fileHandle writeData:chunk];
					}
				} while (nread > 0);
				[fileHandle synchronizeFile];

				if (nread < 0) {
					if (error) {
						*error = [NSError errorWithDomain:STUnzipperErrorDomain code:STUnzipperErrorReadingFile userInfo:@{ @"minizipError": @(ferr) }];
					}
					success = NO;
				}

				unzCloseCurrentFile(uf);
			}

			err = unzGoToNextFile2(uf, &uf_finfo, uf_filename_buf, uf_filename_buf_size, NULL, 0, NULL, 0);
		}
		if (success && err != UNZ_END_OF_LIST_OF_FILE) {
			if (error) {
				*error = [NSError errorWithDomain:STUnzipperErrorDomain code:STUnzipperErrorReadingFile userInfo:@{ @"minizipError": @(err) }];
			}
			success = NO;
		}
	}

	unzClose(uf);

	return success;
}

@end
