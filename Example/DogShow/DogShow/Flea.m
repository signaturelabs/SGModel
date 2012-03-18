
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import "Flea.h"

@implementation Flea

@synthesize color     = color_;
@synthesize lastPoop  = lastPoop_;


#pragma mark -
#pragma mark Initialization & Deallocation

- (void)dealloc {
    
    [color_ release],         color_ = nil;
    [lastPoop_ release],   lastPoop_ = nil;
    [super dealloc];
    
}

@end
