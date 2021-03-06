
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.

#import "SGModelObject.h"
#import <objc/runtime.h>

@interface SGModelObject ()

@property (nonatomic, retain) NSMutableDictionary *unknownProperties;

+ (NSDictionary *)classNamesForPrimitiveTypes;

- (NSString *)keyInDictionary:(NSDictionary *)dictionary
             forPropertyNamed:(NSString *)propertyName 
                  withAliases:(NSDictionary *)propertyAliases;

- (Class)classForPropertyNamed:(NSString *)propertyName
          withPrimitiveClasses:(NSDictionary *)primitiveClasses;

- (Class)classInDictionary:(NSDictionary *)transformers
             withBaseClass:(Class)baseClass
          forPropertyNamed:(NSString *)propertyName;

- (id)representationForObject:(id)object;

@end

@implementation SGModelObject

@synthesize unknownProperties = unknownProperties_;

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)init {
   
    self = [super init];
    
    if (self != nil) {
        unknownProperties_ = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [self init];
    
    if (self != nil) {
        
        [self loadWithDictionary:dictionary];
        
    }
   
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

- (NSArray *)propertyKeys {
    NSMutableArray *propertyKeys;
    Class class;
    
    propertyKeys = [NSMutableArray array]; 
    class        = [self class];
    
    do {
        
        NSUInteger propertyCount;
        objc_property_t *properties; 
        
        propertyCount = 0;
        properties    = class_copyPropertyList(class, &propertyCount);
        
        for (NSUInteger index = 0; index < propertyCount; index++) {
            objc_property_t property;
            const char * propertyName;
            NSString *attributeString;
            NSArray *attributes;
            NSUInteger readOnlyFlagIndex;
            
            property          = properties[index];
            propertyName      = property_getName(property);
            attributeString   = [NSString stringWithUTF8String:property_getAttributes(property)];
            attributes        = [attributeString componentsSeparatedByString:@","];
            
            readOnlyFlagIndex = [attributes indexOfObjectPassingTest:^BOOL(NSString* attribute,
                                                                           NSUInteger index,
                                                                           BOOL *stop) {
                
                if ([attribute isEqualToString:@"R"] == YES) {
                    *stop = YES;
                    return YES;
                } else {
                    return NO;
                }
            }];
            
            if (readOnlyFlagIndex == NSNotFound) {
                if ([propertyKeys containsObject:[NSString stringWithUTF8String:propertyName]] == NO) {
                    [propertyKeys addObject:[NSString stringWithUTF8String:propertyName]];                    
                }
            }
            
        }
        
        free(properties);
        
        class = [class superclass];
        
    } while (class != NULL && class != [NSObject class]);
    
    return propertyKeys;
    
}

- (void)loadWithDictionary:(NSDictionary *)dictionary {
    
    if ([dictionary isKindOfClass:[NSDictionary class]] == YES) {
        
        NSArray *propertyKeys;
        NSDictionary *propertyAliases;
        NSDictionary *reversedPropertyAliases;
        NSDictionary *propertyTransformerClasses;
        NSDictionary *propertyArrayElementClasses;
        NSDictionary *classNamesForPrimitiveTypes;
        NSString *rootContainerKey;
        
        propertyKeys                = [self propertyKeys];
        propertyAliases             = [self propertyAliases];
        reversedPropertyAliases     = [self reversedPropertyAliases];
        propertyTransformerClasses  = [self propertyTransformerClasses];
        propertyArrayElementClasses = [self propertyArrayElementClasses];
        classNamesForPrimitiveTypes = [SGModelObject classNamesForPrimitiveTypes];
        rootContainerKey            = [self rootContainerKey];
        
        if (rootContainerKey != nil && 
            [dictionary objectForKey:rootContainerKey] != nil && 
            [dictionary objectForKey:rootContainerKey] != [NSNull null]) {
            
            dictionary = [dictionary objectForKey:rootContainerKey]; 
        }
        
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id dictionaryKey, id obj, BOOL *stop) {

            id propertyValue;
            NSString *propertyName;
            
            propertyValue = nil;
            propertyName  = [self propertyName:dictionaryKey
                           withReversedAliases:reversedPropertyAliases];
            

            if (propertyName == nil || [propertyName length] <= 0) {

                [[self unknownProperties] setObject:obj forKey:dictionaryKey];
            
            }
            else {
            
                id object;
                Class propertyClass;
                
                object        = [dictionary objectForKey:dictionaryKey];
                propertyClass = [self classForPropertyNamed:propertyName
                                       withPrimitiveClasses:classNamesForPrimitiveTypes];
                
                
                if ([object isKindOfClass:propertyClass] == YES) {
                    
                    if ([propertyClass conformsToProtocol:@protocol(NSMutableCopying)] == YES) {
                        
                        propertyValue = [object mutableCopy];
                        
                        [propertyValue autorelease];
                        
                    } else {
                        
                        propertyValue = object;
                        
                    }
                    
                } else if ([object isKindOfClass:[NSDictionary class]] == YES) {
                    
                    if ([propertyClass isSubclassOfClass:[SGModelObject class]] == YES) {
                        
                        propertyValue = [[propertyClass alloc] initWithDictionary:object];
                        
                        [propertyValue autorelease];
                    }
                    
                } else {
                    Class transformerClass;
                    
                    transformerClass = [self classInDictionary:propertyTransformerClasses
                                                 withBaseClass:[NSValueTransformer class]
                                              forPropertyNamed:propertyName];
                    
                    if ([transformerClass transformedValueClass] == propertyClass) {
                        NSValueTransformer *transformer;
                        id transformedValue;
                        
                        transformer      = [[transformerClass alloc] init];
                        transformedValue = [transformer transformedValue:object];
                        propertyValue    = transformedValue;
                        
                        [transformer release];
                    }
                }
                
                
                if ([propertyValue isKindOfClass:[NSArray class]] == YES) {
                    Class elementClass;
                    
                    elementClass = [self classInDictionary:propertyArrayElementClasses
                                             withBaseClass:[SGModelObject class]
                                          forPropertyNamed:propertyName];
                    
                    if (elementClass != nil) {
                        NSArray *oldArray;
                        NSMutableArray *newArray;
                        
                        oldArray      = (NSArray *)object;
                        newArray      = [NSMutableArray array];
                        propertyValue = newArray;
                        
                        for (id elementObject in oldArray) {
                            
                            if ([elementObject isKindOfClass:[NSDictionary class]] == YES) {
                                NSDictionary *oldElement;
                                SGModelObject *newElement;
                                
                                oldElement = (NSDictionary *)elementObject;
                                newElement = [[elementClass alloc] initWithDictionary:oldElement];
                                
                                [newArray addObject:newElement];
                                [newElement release];
                                
                            }else {
                                
                                [newArray addObject:elementObject];
                                
                            }
                        }
                    }
                }

            
            }
            
            if (propertyValue != nil) {
                [self setValue:propertyValue forKey:propertyName];
            }
            
        }];

    }
}

- (NSMutableDictionary *)propertyTransformerClasses {
    
    return [NSMutableDictionary dictionary];
}

- (NSDictionary *)propertyAliases {
    
    return [NSMutableDictionary dictionary];
}

- (NSDictionary *)propertyArrayElementClasses {
    
    return [NSMutableDictionary dictionary];
}

- (NSString *)rootContainerKey {
    return nil;
}

#pragma mark -
#pragma mark Private Methods

+ (NSDictionary *)classNamesForPrimitiveTypes {
    NSString *numberClassName;
    NSString * valueClassName;
    NSMutableDictionary *dictionary;
    
    numberClassName = NSStringFromClass([NSNumber class]);
    valueClassName  = NSStringFromClass([NSValue class]);
    dictionary      = [NSMutableDictionary dictionary];
    
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(int)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(BOOL)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(long)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(char)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(short)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(float)]];    
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(double)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(long long)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(unsigned int)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(unsigned char)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(unsigned short)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(unsigned long)]];
    [dictionary setObject:numberClassName forKey:[NSString stringWithUTF8String:@encode(unsigned long long)]];
    
    [dictionary setObject:valueClassName forKey:[NSString stringWithUTF8String:@encode(CGPoint)]];
    [dictionary setObject:valueClassName forKey:[NSString stringWithUTF8String:@encode(CGSize)]];
    [dictionary setObject:valueClassName forKey:[NSString stringWithUTF8String:@encode(CGRect)]];
    [dictionary setObject:valueClassName forKey:[NSString stringWithUTF8String:@encode(NSRange)]];
    
    return dictionary;
}


- (NSDictionary *)reversedPropertyAliases  {
    
    NSMutableDictionary *reversedAliases = [NSMutableDictionary dictionary];
    NSDictionary *aliases = [self propertyAliases];
    [aliases enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [reversedAliases setObject:key forKey:obj];
    }];
    return reversedAliases;
    
}

- (NSString *)propertyName:(NSString *)dictionaryKey
       withReversedAliases:(NSDictionary *)reversedPropertyAliases  {

    // do we have a property name for dictionaryKey?
    objc_property_t property;

    property = class_getProperty([self class], [dictionaryKey UTF8String]);

    // if not, do we have a property name for the alias of dictionaryKey
    if (property != nil) {
        return dictionaryKey;
    }
    else {
        NSString *alias = [reversedPropertyAliases objectForKey:dictionaryKey];
        property = class_getProperty([self class], [alias UTF8String]);
        if (property != nil) {
            return alias;
        }
        else {
            return nil;
        }
    }
    
    return nil;
    
    
}

- (NSString *)keyInDictionary:(NSDictionary *)dictionary
             forPropertyNamed:(NSString *)propertyName 
                  withAliases:(NSDictionary *)propertyAliases {
    
    NSArray *dictionaryKeys;
    NSUInteger matchingKeyIndex;
    
    dictionaryKeys   = [dictionary allKeys];     
    matchingKeyIndex = [dictionaryKeys indexOfObjectPassingTest:^BOOL(id keyObject,
                                                                      NSUInteger keyIndex, 
                                                                      BOOL *stopMatching) {
        
        BOOL matchSucessful;
        
        matchSucessful = NO;
        
        if ([keyObject isKindOfClass:[NSString class]] == YES) {
            NSString *key;
            
            key = (NSString *)keyObject;
            
            if ([key caseInsensitiveCompare:propertyName] == NSOrderedSame) {
                
                matchSucessful = YES;
                
            } else {
                id propertyAliasObject;
                
                propertyAliasObject = [propertyAliases objectForKey:propertyName];
                
                if (propertyAliasObject != nil) {
                    
                    if ([propertyAliasObject isKindOfClass:[NSString class]] == YES) {
                        NSString *propertyAlias;
                        
                        propertyAlias = (NSString *)propertyAliasObject;
                        
                        if ([key caseInsensitiveCompare:propertyAlias] == NSOrderedSame) {
                            
                            matchSucessful = YES; 
                            
                        } 
                    }
                }
            }
        }
        
        *stopMatching = matchSucessful;
        
        return matchSucessful;
    }];
    
    
    if (matchingKeyIndex != NSNotFound) {
        
        return [dictionaryKeys objectAtIndex:matchingKeyIndex];
        
    } else {
        
        return nil;
        
    }
}

- (Class)classForPropertyNamed:(NSString *)propertyName
          withPrimitiveClasses:(NSDictionary *)primitiveClasses {
  
    objc_property_t property;
    NSString *attributeString;
    NSArray *attributes;
    Class matchingClass;
    
    property        = class_getProperty([self class], [propertyName UTF8String]);
    attributeString = [NSString stringWithUTF8String:property_getAttributes(property)];
    attributes      = [attributeString componentsSeparatedByString:@","];
    matchingClass   = nil;
    
    if ([attributes count] > 0) {
        NSString *typeAttribute;
        
        typeAttribute = [attributes objectAtIndex:0];
        
        if ([typeAttribute length] > 1) {
            NSString *typeString; 
        
            typeString = [typeAttribute substringFromIndex:1];

            if ([typeString length] > 0) {
         
                if ([typeString hasPrefix:@"@"] == YES && [typeString length] > 3) {
                NSRange substringRange;
                NSString *className;
                
                substringRange = NSMakeRange(2, [typeString length] - 3);
                className      = [typeString substringWithRange:substringRange];
                matchingClass  = NSClassFromString(className);
                
                } else {
                    NSString *className;
                    
                    className     = [primitiveClasses objectForKey:typeString];
                    matchingClass = NSClassFromString(className);
                }
            }
        }
    }
    
    return matchingClass;
}

- (Class)classInDictionary:(NSDictionary *)classDictionary
             withBaseClass:(Class)baseClass 
          forPropertyNamed:(NSString *)propertyName {
    
    id classNameObject;
    Class matchingClass;
    
    classNameObject = [classDictionary objectForKey:propertyName];
    matchingClass   = nil;
    
    if (classNameObject != nil) {
        
        if ([classNameObject isKindOfClass:[NSString class]] == YES) {
            
            NSString *className;
            Class class;
            
            className = (NSString *)classNameObject;
            class     = NSClassFromString(className);
            
            if ([class isSubclassOfClass:baseClass] == YES) {
                
                matchingClass = class;
                
            }
        }   
    }
    
    return matchingClass;
}

- (NSDictionary *)dictionaryRepresentation {
    NSArray *keys;
    
    keys = [self propertyKeys];
   
    return [self dictionaryRepresentationForKeys:keys];

}

- (NSDictionary *)dictionaryRepresentationForKeys:(NSArray *)keys {
    NSMutableDictionary *dictionary;
    NSDictionary *propertyAliases;
    NSDictionary *propertyTransformerClasses;
    
    dictionary                 = [NSMutableDictionary dictionary];
    propertyAliases            = [self propertyAliases];
    propertyTransformerClasses = [self propertyTransformerClasses];

    for (NSString *propertyKey in keys) {
        id propertyValue; 
        NSString *alias;
        NSString *dictionaryKey;
        NSString *transformerClass;
        
        propertyValue    = [self valueForKey:propertyKey];
        alias            = [propertyAliases objectForKey:propertyKey];
        transformerClass = [propertyTransformerClasses objectForKey:propertyKey];
        
        if (alias != nil) {
            dictionaryKey = alias;
        }else {
            dictionaryKey = propertyKey;
        }
        
        if (transformerClass != nil) {
            Class class;
            
            class = NSClassFromString(transformerClass);
            
            if ([class allowsReverseTransformation] == YES) {
                NSValueTransformer *valueTransformer;
                
                valueTransformer = [[class alloc] init];
                propertyValue    = [valueTransformer reverseTransformedValue:propertyValue];
                
                [valueTransformer release];
            }
        }
   
        propertyValue = [self representationForObject:propertyValue];
        
        if (propertyValue != nil) {
            
            [dictionary setObject:propertyValue
                           forKey:dictionaryKey];
        }
    }

    // add objects from unknown fields dictionary
    [[self unknownProperties] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [dictionary setObject:obj forKey:key];
    }];
    
    return dictionary;
}

#pragma mark -
#pragma mark Private Methods

- (id)representationForObject:(id)object {
    
    if ([object isKindOfClass:[NSString class]] == YES ||
        [object isKindOfClass:[NSNumber class]] == YES || 
        [object isKindOfClass:[NSValue class]] == YES) {
        
        return object;
   
    }
    
    if ([object isKindOfClass:[SGModelObject class]] == YES) {
   
        return [object dictionaryRepresentation];
    }
    
    if ([object isKindOfClass:[NSArray class]] == YES) {
        NSMutableArray *array;
        
        array = [NSMutableArray array];
        
        for (id containedObject in object) {
            id representation;
            
            representation = [self representationForObject:containedObject];
            
            if (representation != nil) {
                [array addObject:representation];
            }
        }
        
        return array;
    }
    
    if ([object isKindOfClass:[NSDictionary class]] == YES) {
        NSMutableDictionary *dictionary;
        
        dictionary = [NSMutableDictionary dictionary];
        
        for (id key in [object allKeys]) {
            id containedObject;
            id representaiton;
            
            containedObject = [object objectForKey:key];
            representaiton  = [self representationForObject:containedObject];
            
            if (representaiton != nil) {
                [dictionary setObject:representaiton forKey:key];
            }
        }
        
        return dictionary;
    }
    
    return nil;
   
}

@end
