
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import <Foundation/Foundation.h>

/**
 A standalone, lightweight model object that provides useful machinery commonly needed
 in models.  See the Example directory for usage examples.
 */

@interface SGModelObject : NSObject

/**
 Initialize using the fields from the dictionary.  Only fields in the dictionary which have an
 exact match with a property in the model, or a match via an alias, will have their values loaded
 in the model's properties.  All other fields will be ignored.
 
 This can recursively initialize an object graph, if for example this model contains fields which
 are other SGModelObject's, or collections of SGModelObjects.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 If the object has already been initialized, this can be called instead of initWithDictionary.
 */
- (void)loadWithDictionary:(NSDictionary *)dictionary;

/**
 Return the set of property keys for this model.  Each property key will be a string containing the
 name (aka "key") of the property.
 */
- (NSOrderedSet *)propertyKeys;  

/**
 A mapping between aliases and property keys.  This should be overridden by subclasses in order
 to allow models to have different names for the same fields that are given in the dictionary
 passed into initWithDictionary.
 */
- (NSMutableDictionary *)propertyAliases;

/**
 A dictionary which specifies the transformer class for a given field.
 */
- (NSMutableDictionary *)propertyTransformerClasses;

/**
 Specify which type of SGModelObject classes are contained in NSArray properties, so they can
 be resolved into objects.
 */
- (NSMutableDictionary *)propertyArrayElementClasses;

/**
 Export this model into a dictionary representation.  It will apply reverse mapping of aliases and
 transformations.  Like initWithDictionary, can traverse object graph of arbitrary depth.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 Export this model into a dictionary representation, but specify a subset of the top level keys that
 will be included in the dictionary.
 */
- (NSDictionary *)dictionaryRepresentationForKeys:(NSSet *)keys;

@end
