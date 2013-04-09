//
//  MISwizzledMethodVO.m
//  MockInject
//
//  Created by Matt Ganski on 4/9/13.
//  Copyright (c) 2013 FitNerds. All rights reserved.
//

#import "MISwizzledMethodVO.h"

@implementation MISwizzledMethodVO

- (id)initWithOriginalMethod:(Method)originalMethod overrideMethod:(Method)overrideMethod{
    self = [super init];
    self.originalMethod = originalMethod;
    self.overrideMethod = overrideMethod;
    return self;
}

@end
