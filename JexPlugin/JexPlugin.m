//
//  JexPlugin.m
//  JexPlugin
//
//  Created by Jiangy on 13-11-1.
//  Copyright (c) 2013年 Jiangy. All rights reserved.
//

#import "JexPlugin.h"
#import "NSLineString.h"

typedef enum CopyDirection {
	CD_UP = 1,
    CD_DOWN
} CopyDirection;

@interface NSString (Jex)
- (NSString *)trim;
@end

@implementation NSString (Jex)
- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
@end

#pragma mark -

@implementation JexPlugin

+ (void)pluginDidLoad:(NSBundle *)plugin {
    [self shared];
}

+ (id)shared {
    static dispatch_once_t once;
    static id instance = nil;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void) applicationDidFinishLaunching: (NSNotification*) noti {
    NSMenu * menu = [NSApp mainMenu];
    NSMenuItem * epMenuItem = [menu itemWithTitle:@"XEP"];
    if (epMenuItem) {
        // NOTE: Dividing line
        [[epMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        // NOTE: Uppercase
        NSMenuItem * jexMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Uppercase"
                                                                                        action:@selector(toUppercase:)
                                                                                 keyEquivalent:@"U"];
        [jexMenuItem setTarget:self];
        [jexMenuItem setKeyEquivalentModifierMask:(NSShiftKeyMask | NSControlKeyMask)];
        [[epMenuItem submenu] addItem:jexMenuItem];
        [jexMenuItem release];
        // NOTE: Lowercase
        jexMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Lowercase"
                                                                           action:@selector(toLowercase:)
                                                                    keyEquivalent:@"L"];
        [jexMenuItem setTarget:self];
        [jexMenuItem setKeyEquivalentModifierMask:(NSShiftKeyMask | NSControlKeyMask)];
        [[epMenuItem submenu] addItem:jexMenuItem];
        [jexMenuItem release];
        
    } else {
        NSMenu * jex = [[[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Jex"] autorelease];
        
        // NOTE: Uppercase
        NSMenuItem * jexMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Uppercase"
                                                                                        action:@selector(toUppercase:)
                                                                                 keyEquivalent:@"U"];
        [jexMenuItem setTarget:self];
        [jexMenuItem setKeyEquivalentModifierMask:(NSShiftKeyMask | NSControlKeyMask)];
        [jex addItem:jexMenuItem];
        [jexMenuItem release];
        
        // NOTE: Lowercase
        jexMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Lowercase"
                                                                           action:@selector(toLowercase:)
                                                                    keyEquivalent:@"L"];
        [jexMenuItem setTarget:self];
        [jexMenuItem setKeyEquivalentModifierMask:(NSShiftKeyMask | NSControlKeyMask)];
        [jex addItem:jexMenuItem];
        [jexMenuItem release];
        
        // NOTE: Dividing line
        [jex addItem:[NSMenuItem separatorItem]];
        
        // NOTE: Copy line up
        UniChar a;
        a = 63232;
        jexMenuItem	= [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Copy line up"
                                                                           action:@selector(copyLineUp:)
                                                                    keyEquivalent:[NSString stringWithCharacters:&a length:1]];
        [jexMenuItem setTarget:self];
        [jexMenuItem setKeyEquivalentModifierMask:(NSControlKeyMask | NSAlternateKeyMask)];
        [jex addItem:jexMenuItem];
        [jexMenuItem release];
        
        // NOTE: Copy line down
        a = 63233;
        jexMenuItem	= [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Copy line down"
                                                                           action:@selector(copyLineDown:)
                                                                    keyEquivalent:[NSString stringWithCharacters:&a length:1]];
        [jexMenuItem setKeyEquivalentModifierMask:(NSControlKeyMask | NSAlternateKeyMask)];
        [jexMenuItem setTarget:self];
        [jex addItem:jexMenuItem];
        [jexMenuItem release];
        
        // NOTE: Delete line
        jexMenuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Delete line"
                                                                           action:@selector(deleteLine:)
                                                                    keyEquivalent:@"-"];
        [jexMenuItem setKeyEquivalentModifierMask:(NSCommandKeyMask)];
        [jexMenuItem setTarget:self];
        [jex addItem:jexMenuItem];
        [jexMenuItem release];
        
        // NOTE: Add to main menu
        NSArray * items	= [menu itemArray];
        NSMenuItem * mi = [[NSMenuItem alloc] initWithTitle:@"Jex" action:nil keyEquivalent:@""];
        mi.submenu = jex;
        [menu insertItem:mi atIndex:[items count] - 1];
        [mi release];
    }
}

#pragma mark -

- (void)toUppercase:(id)sender {
    NSWindow * nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder * responder = [nsKeyWindow firstResponder];
	NSString * resname = [[responder class] description];
    
	if (![resname isEqualToString:@"DVTSourceTextView"]) {
		return;
	}
    
	NSTextView * tv = (NSTextView *)responder;
	NSRange range = tv.selectedRange;
    NSString * text = tv.textStorage.string;
    NSString * selectedText = [text substringWithRange:range];
    
    if (tv && selectedText && ![[selectedText trim] isEqualToString:@""]) {
        [tv.textStorage replaceCharactersInRange:range withString:[selectedText uppercaseString]];
        [tv setSelectedRange:range];
    }
}

- (void)toLowercase:(id)sender {
    NSWindow * nsKeyWindow = [[NSApplication sharedApplication] keyWindow];
	NSResponder * responder = [nsKeyWindow firstResponder];
	NSString * resname = [[responder class] description];
    
	if (![resname isEqualToString:@"DVTSourceTextView"]) {
		return;
	}
    
	NSTextView * tv = (NSTextView *)responder;
	NSRange range = tv.selectedRange;
    NSString * text = tv.textStorage.string;
    NSString * selectedText = [text substringWithRange:range];
    
    if (tv && selectedText && ![[selectedText trim] isEqualToString:@""]) {
        [tv.textStorage replaceCharactersInRange:range withString:[selectedText lowercaseString]];
        [tv setSelectedRange:range];
    }
}

#pragma makr -

- (void)deleteLine:(id)sender
{
	NSWindow	*nsKeyWindow	= [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder		= [nsKeyWindow firstResponder];
	NSString	*resname		= [[responder class] description];
    
	if (![resname isEqualToString:@"DVTSourceTextView"]) {
		return;
	}
    
	NSTextView		*tv		= (NSTextView *)responder;
	NSRange			range	= tv.selectedRange;
	NSLineString	*ls		= [NSLineString lineStringWith:[[tv textStorage] string]];
	NSUInteger		cline	= [ls lineOfLocation:range.location];
    
	if (range.length > 0) {
		if ('\n' == [ls.targetStr characterAtIndex:range.location + range.length - 1]) {
			range.length -= 1;
		}
        
		NSRange srange	= [ls rangeOfLineNumber:[ls lineOfLocation:range.location]];
		NSRange erange	= [ls rangeOfLineNumber:[ls lineOfLocation:(range.location + range.length)]];
		range = NSMakeRange(srange.location, erange.location + erange.length + 1 - srange.location);
	} else {
		range = [ls rangeOfLineNumber:cline];
		range.length++;
	}
    
	[tv insertText:@"" replacementRange:range];
}

- (void)copyLine:(CopyDirection)direction {
	NSWindow	*nsKeyWindow	= [[NSApplication sharedApplication] keyWindow];
	NSResponder *responder		= [nsKeyWindow firstResponder];
	NSString	*resname		= [[responder class] description];
    
	if (![resname isEqualToString:@"DVTSourceTextView"]) {
		return;
	}
    
	NSTextView		*tv		= (NSTextView *)responder;
	NSRange			range	= tv.selectedRange;
	NSLineString	*ls		= [NSLineString lineStringWith:[[tv textStorage] string]];
	NSUInteger		cline	= [ls lineOfLocation:range.location];
    
	NSString	*ltext;
	NSRange		srg;
    
	if (range.length > 0) {
		if ('\n' == [ls.targetStr characterAtIndex:range.location + range.length - 1]) {
			range.length -= 1;
		}
        
		NSRange srange	= [ls rangeOfLineNumber:[ls lineOfLocation:range.location]];
		NSRange erange	= [ls rangeOfLineNumber:[ls lineOfLocation:(range.location + range.length)]];
		range	= NSMakeRange(srange.location, erange.location + erange.length + 1 - srange.location);
		ltext	= [ls.targetStr substringWithRange:range];
        
		if (direction == CD_UP) {
			srg = range;
		} else {
			srg = NSMakeRange(range.length + range.location, ltext.length);
		}
        
		range = NSMakeRange(range.length + range.location, 0);
	} else {
		ltext			= [[ls stringOfLineNumber:cline] stringByAppendingString:@"\n"];
		range			= [ls rangeOfLineNumber:cline];
		range.location	= range.location + range.length + 1;
		range.length	= 0;
        
		if (direction == CD_UP) {
			srg = tv.selectedRange;
		} else {
			srg = NSMakeRange(range.length + range.location + ltext.length - 1, 0);
		}
	}
    
	[tv insertText:ltext replacementRange:range];
	tv.selectedRange = srg;
}

- (void)copyLineUp:(id)sender {
	@synchronized(self) {
		@try {
			[self copyLine:CD_UP];
		}
		@catch(NSException *exception) {
			NSLog(@"copy line up error:%@", [exception debugDescription]);
		}
	}
}

- (void)copyLineDown:(id)sender {
	@synchronized(self) {
		@try {
			[self copyLine:CD_DOWN];
		}
		@catch(NSException *exception) {
			NSLog(@"copy line down error:%@", [exception debugDescription]);
		}
	}
}

@end
