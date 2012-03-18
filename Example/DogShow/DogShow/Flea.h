
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import <UIKit/UIKit.h>
#import "SGModelObject.h"
#import "Poop.h"

/**
 A flea, a small blood sucking insect.
 */

@interface Flea : SGModelObject

@property (nonatomic, readwrite, retain) NSString *color;

@property (nonatomic, readwrite, retain) Poop *lastPoop;

@end
