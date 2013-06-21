//
//  MIMocker.h
//  MockInject
//
//  Created by Matt Ganski on 4/9/13.
//  Copyright (c) 2013 FitNerds. All rights reserved.
//

@interface MIMocker : NSObject

+ (id)globalMockForClass:(Class)clazz initSelector:(SEL)initSelector;
+ (id)globalMockForClass:(Class)clazz initSelector:(SEL)initSelector overrideClass:(Class)overrideClass;
+ (id)classMockForClass:(Class)clazz initSelector:(SEL)initSelector overrideClass:(Class)overrideClass;
+ (void)undoMockForClass:(Class)clazz;

@end
