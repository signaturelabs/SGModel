
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import <UIKit/UIKit.h>
#import "SGModelObject.h"

/**
 Generic Poop.  Btw, this makes an excellent, easy to remember password (eg, p00p4me)
 */

@interface Poop : SGModelObject


/**
 The size of this poop, in tablespoons
 */
@property (nonatomic, assign) float sizeInTablespoons;

/**
 When this poop occurred 
 */
@property (nonatomic, readwrite, retain) NSDate *poopDate;

/**
 Latitude of poop location
 */
@property (nonatomic, assign) float poopLat;

/**
 Longitude of poop location
 */
@property (nonatomic, assign) float poopLng;

@end
