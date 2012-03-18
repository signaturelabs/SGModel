
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import "Poop.h"

@implementation Poop

@synthesize sizeInTablespoons  = sizeInTablespoons_;
@synthesize poopDate  = poopDate_;
@synthesize poopLat  = poopLat_;
@synthesize poopLng  = poopLng_;

#pragma mark -
#pragma mark Initialization & Deallocation

- (void)dealloc {
    
    [poopDate_ release],                     poopDate_ = nil;
    [super dealloc];
    
}

#pragma mark -
#pragma mark SGModelObject Overrides

- (NSMutableDictionary *)propertyAliases {
    NSMutableDictionary *aliases;
    
    aliases = [super propertyAliases];
    
    [aliases setObject:@"amount"
                forKey:@"sizeInTablespoons"];
    
    return aliases;
}


@end
