//
//  Errors.h
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#ifndef Instagram_Errors_h
#define Instagram_Errors_h

static NSString *MSErrorDomain = @"maratsarbasov.instagram.app";

enum {
    MSInvalidAccessToken = 1000,
    MSJSONParsingError,
    MSUserNotFound,
    MSNoConnection,
    MSUnknownError,
    MSNoMorePhotos,
    MSImageNotFound
};

#endif
