
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.


#import "DogOwner.h"

@implementation DogOwner

@synthesize name = name_;


#pragma mark -
#pragma mark Initialization & Deallocation

- (void)dealloc {
    
    [name_ release],   name_ = nil;
    [super dealloc];
    
}

@end
