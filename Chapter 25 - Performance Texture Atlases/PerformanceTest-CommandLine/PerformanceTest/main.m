//
//  main.m
//  PerformanceTest
//
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
// Fix for Beta 6 Xcode Issue here: https://devforums.apple.com/thread/197966?start=50&tstart=0
typedef int (*PYStdWriter)(void *, const char *, int);
static PYStdWriter _oldStdWrite;

int __pyStderrWrite(void *inFD, const char *buffer, int size)
{
    if ( strncmp(buffer, "AssertMacros:", 13) == 0 ) {
        return 0;
    }
    return _oldStdWrite(inFD, buffer, size);
}


int main(int argc, char * argv[])
{
    _oldStdWrite = stderr->_write;      // Fix for iOS 7 Beta 6
    stderr->_write = __pyStderrWrite;   // Fix for iOS 7 Beta 6
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
