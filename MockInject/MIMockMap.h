//
//  MIMockMap.h
//  MockInject
//
//  Created by Matt Ganski on 4/9/13.
//  Copyright (c) 2013 FitNerds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIMockMap : NSObject

+ (void)setObject:(id)object forKey:(id<NSCopying>)aKey;
+ (id)objectForKey:(id<NSCopying>)aKey;

@end
