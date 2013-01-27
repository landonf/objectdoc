//
//  main.m
//  doctool
//
//  Created by Landon Fuller on 1/26/13.
//  Copyright (c) 2013 Landon Fuller. All rights reserved.
//

#import <ObjectDoc/ObjectDoc.h>

int main (int argc, const char *argv[]) {
    /* Run clang via dispatch */
    dispatch_async(dispatch_get_main_queue(), ^{
        exit(RunTool(argc, argv));
    });

    /* Park in event loop */
    dispatch_main();
    return 0;
}