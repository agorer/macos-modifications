// From: https://stackoverflow.com/questions/30336086/make-shift3-produce-not-%C2%A3-on-osx-by-code
// compile and run from the commandline with:
//    clang -fobjc-arc -framework Cocoa  ./foo.m  -o foo
//    sudo ./foo 

#import <Foundation/Foundation.h>
#import <AppKit/NSEvent.h>

typedef CFMachPortRef EventTap;

// - - - - - - - - - - - - - - - - - - - - -

@interface KeyChanger : NSObject
{
@private
    EventTap            _eventTap;
    CFRunLoopSourceRef  _runLoopSource;
    CGEventRef          _lastEvent;
}
@end

// - - - - - - - - - - - - - - - - - - - - -

CGEventRef _tapCallback(
                        CGEventTapProxy proxy,
                        CGEventType     type,
                        CGEventRef      event,
                        KeyChanger*     listener
                        );

// - - - - - - - - - - - - - - - - - - - - -

@implementation KeyChanger

- (BOOL)tapEvents
{
    if (!_eventTap) {
        NSLog(@"Initializing an event tap.");

        _eventTap = CGEventTapCreate(kCGSessionEventTap,
                                     kCGTailAppendEventTap,
                                     kCGEventTapOptionDefault,
                                     CGEventMaskBit( kCGEventKeyDown ),
                                     (CGEventTapCallBack)_tapCallback,
                                     (__bridge void *)(self));
        if (!_eventTap) {
            NSLog(@"unable to create event tap. must run as root or "
                    "add privlidges for assistive devices to this app.");
            return NO;
        }
    }
    CGEventTapEnable(_eventTap, TRUE);

    return [self isTapActive];
}

- (BOOL)isTapActive
{
    return CGEventTapIsEnabled(_eventTap);
}

- (void)listen
{
    if( ! _runLoopSource ) {
        if( _eventTap ) { //dont use [self tapActive]
            _runLoopSource = CFMachPortCreateRunLoopSource( kCFAllocatorDefault,
                                                            _eventTap, 0);
            // Add to the current run loop.
            CFRunLoopAddSource( CFRunLoopGetCurrent(), _runLoopSource,
                                kCFRunLoopCommonModes);

            NSLog(@"Registering event tap as run loop source.");
            CFRunLoopRun();
        }else{
            NSLog(@"No Event tap in place! You will need to call "
                    "listen after tapEvents to get events.");
        }
    }
}

- (CGEventRef)processEvent:(CGEventRef)cgEvent
{
    NSEvent* event = [NSEvent eventWithCGEvent:cgEvent];

    NSUInteger modifiers = [event modifierFlags] &
        (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagShift | NSEventModifierFlagControl);

    // Keycodes are dependent on keyboard configurations, could be looked using the app https://apps.apple.com/tr/app/key-codes/id414568915?l=tr&mt=12
    enum {
      kVK_BACKSLASH = 0xa,
      kVK_ANSI_1 = 0x12,
      kVK_ANSI_2 = 0x13,
      kVK_ANSI_3 = 0x14,
      kVK_ANSI_NTILDE = 0x29,
    };

    if (event.keyCode == kVK_BACKSLASH && modifiers == NSEventModifierFlagOption) {
      event = [NSEvent keyEventWithType: event.type
                               location: NSZeroPoint
                          modifierFlags: event.modifierFlags & ! NSEventModifierFlagOption
                              timestamp: event.timestamp
                           windowNumber: event.windowNumber
                                context: nil // event.context is deprecated and only returns `nil`
                             characters: @"\\"
                       charactersIgnoringModifiers: @"\\"
                              isARepeat: event.isARepeat
                                keyCode: event.keyCode];
    }

    if (event.keyCode == kVK_ANSI_1 && modifiers == NSEventModifierFlagOption) {
      event = [NSEvent keyEventWithType: event.type
                               location: NSZeroPoint
                          modifierFlags: event.modifierFlags & ! NSEventModifierFlagOption
                              timestamp: event.timestamp
                           windowNumber: event.windowNumber
                                context: nil // event.context is deprecated and only returns `nil`
                             characters: @"|"
                       charactersIgnoringModifiers: @"|"
                              isARepeat: event.isARepeat
                                keyCode: event.keyCode];
    }

    if (event.keyCode == kVK_ANSI_2 && modifiers == NSEventModifierFlagOption) {
      event = [NSEvent keyEventWithType: event.type
                               location: NSZeroPoint
                          modifierFlags: event.modifierFlags & ! NSEventModifierFlagOption
                              timestamp: event.timestamp
                           windowNumber: event.windowNumber
                                context: nil // event.context is deprecated and only returns `nil`
                             characters: @"@"
                       charactersIgnoringModifiers: @"@"
                              isARepeat: event.isARepeat
                                keyCode: event.keyCode];
    }

    if (event.keyCode == kVK_ANSI_3 && modifiers == NSEventModifierFlagOption) {
      event = [NSEvent keyEventWithType: event.type
                               location: NSZeroPoint
                          modifierFlags: event.modifierFlags & ! NSEventModifierFlagOption
                              timestamp: event.timestamp
                           windowNumber: event.windowNumber
                                context: nil // event.context is deprecated and only returns `nil`
                             characters: @"#"
                       charactersIgnoringModifiers: @"#"
                              isARepeat: event.isARepeat
                                keyCode: event.keyCode];
    }

    if (event.keyCode == kVK_ANSI_NTILDE && modifiers == NSEventModifierFlagOption) {
      event = [NSEvent keyEventWithType: event.type
                               location: NSZeroPoint
                          modifierFlags: event.modifierFlags & ! NSEventModifierFlagOption
                              timestamp: event.timestamp
                           windowNumber: event.windowNumber
                                context: nil // event.context is deprecated and only returns `nil`
                             characters: @"~"
                       charactersIgnoringModifiers: @"~"
                              isARepeat: event.isARepeat
                                keyCode: event.keyCode];
    }

    _lastEvent = [event CGEvent];
    CFRetain(_lastEvent); // must retain the event. will be released by the system
    return _lastEvent;
}

- (void)dealloc
{
    if( _runLoopSource ) {
        CFRunLoopRemoveSource( CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopCommonModes );
        CFRelease( _runLoopSource );
    }
    if( _eventTap ) {
        //kill the event tap
        CGEventTapEnable( _eventTap, FALSE );
        CFRelease( _eventTap );
    }
}

@end

// - - - - - - - - - - - - - - - - - - - - -

CGEventRef _tapCallback(
                        CGEventTapProxy proxy,
                        CGEventType     type,
                        CGEventRef      event,
                        KeyChanger*     listener
                        )
{
    //Do not make the NSEvent here.
    //NSEvent will throw an exception if we try to make an event from the tap timout type
    @autoreleasepool {
        if( type == kCGEventTapDisabledByTimeout ) {
            NSLog(@"event tap has timed out, re-enabling tap");
            [listener tapEvents];
            return nil;
        }
        if( type != kCGEventTapDisabledByUserInput ) {
            return [listener processEvent:event];
        }
    }
    return event;
}

// - - - - - - - - - - - - - - - - - - - - -

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        KeyChanger* keyChanger = [KeyChanger new];
        [keyChanger tapEvents];
        [keyChanger listen];//blocking call.
    }
    return 0;
}
