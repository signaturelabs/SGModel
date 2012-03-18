
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import "Dog.h"
#import "Flea.h"
#import "DogPoop.h"

@implementation Dog

@synthesize name  = name_;
@synthesize breed = breed_;
@synthesize mommy = mommy_;
@synthesize fleas = fleas_;
@synthesize poops = poops_;


#pragma mark -
#pragma mark Initialization & Deallocation

- (void)dealloc {
    
    [name_ release],   name_ = nil;
    [breed_ release], breed_ = nil;
    [mommy_ release], mommy_ = nil;
    [fleas_ release], fleas_ = nil;
    [poops_ release], poops_ = nil;
    [super dealloc];
    
}


#pragma mark -
#pragma mark SGModelObject Overrides

- (NSMutableDictionary *)propertyAliases {
    NSMutableDictionary *aliases;
    
    aliases = [super propertyAliases];
    
    [aliases setObject:@"kind"
                forKey:@"breed"];
    
    return aliases;
}

- (NSMutableDictionary *)propertyArrayElementClasses {
    NSMutableDictionary *arrayElementClasses;
    
    arrayElementClasses = [super propertyArrayElementClasses];
    
    [arrayElementClasses setObject:NSStringFromClass([Flea class]) 
                            forKey:@"fleas"];
    
    [arrayElementClasses setObject:NSStringFromClass([DogPoop class]) 
                            forKey:@"poops"];
    
    return arrayElementClasses;
}


@end
