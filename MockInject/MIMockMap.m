//
//  MIMockMap.m
//  MockInject
//
//  Created by Matt Ganski on 4/9/13.
//  Copyright (c) 2013 FitNerds. All rights reserved.
//

#import "MIMockMap.h"

@implementation MIMockMap

static NSMutableDictionary *map = nil;

+ (void)setObject:(id)object forKey:(id<NSCopying>)aKey{
    if(map == nil)
        map = [[NSMutableDictionary alloc] init];
    [map setObject:object forKey:aKey];
}

+ (id)objectForKey:(id<NSCopying>)aKey{
    if(map == nil)
        map = [[NSMutableDictionary alloc] init];
    return [map objectForKey:aKey];
}

@end
