//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot

#import "STZip.h"
#import "zip.h"


NSString * const STZipErrorDomain = @"STZip";


static NSString * __attribute((overloadable)) STZipErrorString(int ze, int se);
static NSString * __attribute((overloadable)) STZipErrorString(struct zip *z) {
	int ze, se;
	zip_error_get(z, &ze, &se);
	return STZipErrorString(ze, se);
}
static NSString * __attribute((overloadable)) STZipErrorString(int ze, int se) {
	char buf[256] = { 0 };
	int len = zip_error_to_str(buf, 255, ze, se);
	return [[NSString alloc] initWithBytes:buf length:(NSUInteger)len encoding:NSUTF8StringEncoding];
}
static NSDictionary * __attribute((overloadable)) STZipErrorDictionary(int ze, int se);
static NSDictionary * __attribute((overloadable)) STZipErrorDictionary(struct zip *z) {
	int ze, se;
	zip_error_get(z, &ze, &se);
	return STZipErrorDictionary(ze, se);
}
static NSDictionary * __attribute((overloadable)) STZipErrorDictionary(int ze, int se) {
	return @{
		@"libzip_zerr": @(ze),
		@"libzip_serr": @(se),
		@"libzip_str": STZipErrorString(ze, se),
	};
}


@implementation STZip {
@private
	struct zip *_zip;
}

- (id)init {
	return [self initWithPath:nil error:NULL];
}
- (id)initWithPath:(NSString *)path {
	return [self initWithPath:path error:NULL];
}
- (id)initWithPath:(NSString *)path error:(NSError * __autoreleasing *)error {
	NSParameterAssert([path length]);
	if (!path) {
		return nil;
	}

	int err = 0;
	struct zip *zip = zip_open([path fileSystemRepresentation], 0, &err);
	if (!zip) {
		if (error) {
			*error = [NSError errorWithDomain:STZipErrorDomain code:STZipErrorOpeningFile userInfo:STZipErrorDictionary(err, 0)];
		}
		return nil;
	}

	if ((self = [super init])) {
		_zip = zip;
	} else {
		zip_close(zip);
	}
	return self;
}

- (void)dealloc {
	if (_zip) {
		zip_discard(_zip), _zip = NULL;
	}
}

- (NSUInteger)numberOfFiles {
	int num_files = zip_get_num_files(_zip);
	if (num_files < 0) {
		return 0;
	}
	return (NSUInteger)num_files;
}

- (NSSet *)filenames {
	return [self filenamesWithError:nil];
}
- (NSSet *)filenamesWithError:(NSError * __autoreleasing *)error {
	int num_files = zip_get_num_files(_zip);
	if (num_files < 0) {
		return [NSSet set];
	}

	NSMutableSet *filenames = [[NSMutableSet alloc] initWithCapacity:(NSUInteger)num_files];

	struct zip_stat zst;
	for (zip_uint64_t i = 0; i < (zip_uint64_t)num_files; ++i) {
		int rv = zip_stat_index(_zip, i, 0, &zst);
		if (rv || !(zst.valid & ZIP_STAT_NAME)) {
			if (error) {
				*error = [NSError errorWithDomain:STZipErrorDomain code:STZipErrorUnknown userInfo:STZipErrorDictionary(_zip)];
			}
			return nil;
		}
		NSString *filename = [[NSString alloc] initWithUTF8String:zst.name];
		[filenames addObject:filename];
	}

	return [filenames copy];
}

- (NSData *)dataWithContentsOfFileAtPath:(NSString *)path {
	return [self dataWithContentsOfFileAtPath:path error:nil];
}
- (NSData *)dataWithContentsOfFileAtPath:(NSString *)path error:(NSError * __autoreleasing *)error {
	struct zip_stat zst;
	int rv = zip_stat(_zip, [path UTF8String], 0, &zst);
	if (rv < 0) {
		if (error) {
			*error = [NSError errorWithDomain:STZipErrorDomain code:STZipErrorUnknown userInfo:STZipErrorDictionary(_zip)];
		}
		return nil;
	}

	struct zip_file *zf = zip_fopen_index(_zip, zst.index, 0);
	if (!zf) {
		if (error) {
			*error = [NSError errorWithDomain:STZipErrorDomain code:STZipErrorUnknown userInfo:STZipErrorDictionary(_zip)];
		}
		return nil;
	}

	zip_uint64_t filedatabuf_len = zst.size;
	char *filedatabuf = malloc(filedatabuf_len);
	if (!filedatabuf) {
		if (error) {
			*error = [NSError errorWithDomain:STZipErrorDomain code:STZipErrorUnknown userInfo:STZipErrorDictionary(0, errno)];
		}
		zip_fclose(zf);
		return nil;
	}
	NSData *data = [[NSData alloc] initWithBytesNoCopy:filedatabuf length:filedatabuf_len freeWhenDone:YES];

	zip_int64_t ntoread = (zip_int64_t)filedatabuf_len; // XXX chunk?
	zip_int64_t nread = zip_fread(zf, filedatabuf, (zip_uint64_t)ntoread);
	if (nread != ntoread) {
		if (error) {
			*error = [NSError errorWithDomain:STZipErrorDomain code:STZipErrorUnknown userInfo:STZipErrorDictionary(0, errno)];
		}
		zip_fclose(zf);
		return nil;
	}

	return data;
}

@end
