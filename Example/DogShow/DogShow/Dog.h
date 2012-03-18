
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import <UIKit/UIKit.h>
#import "SGModelObject.h"
#import "DogOwner.h"

/**
 A model Dog
 */

@interface Dog : SGModelObject

@property (nonatomic, readwrite, retain) NSString *name;
@property (nonatomic, readwrite, retain) NSString *breed;
@property (nonatomic, readwrite, retain) DogOwner *mommy;
@property (nonatomic, readwrite, retain) NSArray *fleas;
@property (nonatomic, readwrite, retain) NSArray *poops;

@end
