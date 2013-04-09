//
//  MISwizzledMethodVO.h
//  MockInject
//
//  Created by Matt Ganski on 4/9/13.
//  Copyright (c) 2013 FitNerds. All rights reserved.
//

#import <objc/runtime.h>

@interface MISwizzledMethodVO : NSObject

@property (nonatomic) Method originalMethod;
@property (nonatomic) Method overrideMethod;

- (id)initWithOriginalMethod:(Method)originalMethod overrideMethod:(Method)overrideMethod;

@end
