
// Copyright (c) 2011 Signature Labs, Inc (http://getsignature.com/)
// See LICENSE file for license information.


#import "DogShow.h"
#import "Dog.h"

@interface DogShow()

- (NSDictionary *)doggyDictionaryFromJson:(NSString *)dogName;
- (void)logAsJson:(NSDictionary *)dictionary;


@end

@implementation DogShow

#pragma mark -
#pragma mark Public

- (void)run {
    
    // Read a dog into a model from a dictionary
    NSDictionary *buckeyeDictionary = [self doggyDictionaryFromJson:@"buckeye"];        
    Dog *buckeye = [[Dog alloc] initWithDictionary:buckeyeDictionary];
    
    // Get the dictionary representation and output as JSON
    NSDictionary *buckeyeDictionaryRepresentation = [buckeye dictionaryRepresentation];
    [self logAsJson:buckeyeDictionaryRepresentation];
    
}

#pragma mark -
#pragma mark Private

- (NSDictionary *)doggyDictionaryFromJson:(NSString *)dogName {

    NSString *filePath = [[NSBundle mainBundle] pathForResource:dogName ofType:@"json"];  
    NSData *data = [NSData dataWithContentsOfFile:filePath];  

    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data 
                                            options:kNilOptions error:&error];

    return (NSDictionary *) result;

}

- (void)logAsJson:(NSDictionary *)dictionary {
    
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:dictionary 
                                                options:kNilOptions error:&error];
    
    NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"%@", resultString);
    
}



@end
