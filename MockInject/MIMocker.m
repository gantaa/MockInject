//
//  MIMocker.m
//  MockInject
//
//  Created by Matt Ganski on 4/9/13.
//  Copyright (c) 2013 FitNerds. All rights reserved.
//

#import "MIMocker.h"
#import "Kiwi.h"
#import "MIMockMap.h"
#import "MISwizzledMethodVO.h"
#include <objc/runtime.h>

@implementation MIMocker

static NSMutableDictionary *originalImplementations;

+ (id)globalMockForClass:(Class)clazz initSelector:(SEL)initSelector{
    [self swizzleMethodForClass:clazz origSelector:initSelector overrideClass:[self class] overrideSelector:@selector(overrideInit) isClassMethod:NO];
    return [self getMockForClass:clazz];
}

+ (id)globalMockForClass:(Class)clazz initSelector:(SEL)initSelector overrideClass:(Class)overrideClass overrideSelector:(SEL)overrideSelector{
    [self swizzleMethodForClass:clazz origSelector:initSelector overrideClass:overrideClass overrideSelector:overrideSelector isClassMethod:NO];
    return [self getMockForClass:clazz];
}

+ (id)classMockForClass:(Class)clazz initSelector:(SEL)initSelector overrideClass:(Class)overrideClass overrideSelector:(SEL)overrideSelector{
    [self swizzleMethodForClass:clazz origSelector:initSelector overrideClass:overrideClass overrideSelector:overrideSelector isClassMethod:YES];
    return [self getMockForClass:clazz];
}

+ (void)swizzleMethodForClass:(Class)clazz origSelector:(SEL)origSelector overrideClass:(Class)overrideClass overrideSelector:(SEL)overrideSelector isClassMethod:(BOOL)isClassMethod{
    Method origMethod = isClassMethod ?
    class_getClassMethod(clazz, origSelector) :
    class_getInstanceMethod(clazz, origSelector);
    Method overrideMethod = isClassMethod ?
    class_getClassMethod(overrideClass, overrideSelector) :
    class_getInstanceMethod(overrideClass, overrideSelector);
    [self storeUndoMock:origMethod overriderMethod:overrideMethod forClass:clazz];
    if(!isClassMethod && class_addMethod(clazz, origSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))){
        class_replaceMethod(clazz, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

+ (void)storeUndoMock:(Method)origMethod overriderMethod:(Method)overrideMethod forClass:(Class)clazz{
    if(!originalImplementations)
        originalImplementations = [[NSMutableDictionary alloc] init];
    MISwizzledMethodVO *methods = [[MISwizzledMethodVO alloc] initWithOriginalMethod:origMethod overrideMethod:overrideMethod];
    [originalImplementations setObject:methods forKey:NSStringFromClass(clazz)];
}

+ (void)undoMockForClass:(Class)clazz{
    MISwizzledMethodVO *methods = [originalImplementations objectForKey:NSStringFromClass(clazz)];
    method_exchangeImplementations(methods.overrideMethod, methods.originalMethod);
}

+ (id)getMockForClass:(Class)clazz{
    id mock = [KWMock nullMockForClass:clazz];
    [MIMockMap setObject:mock forKey:NSStringFromClass(clazz)];
    return mock;
}

- (id)overrideInit{
    return [MIMockMap objectForKey:NSStringFromClass([self class])];
}

@end
