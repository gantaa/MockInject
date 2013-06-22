# Overview

MockInject allows developers who use the Kiwi testing framework to globally mock any Objective C class by overriding the init method of the developer's choice.  Without this library, objects that are instantiated and initialized internally in a class cannot be mocked up or asserted unless the developer makes the object a public property or creates a public method for instantiation and overrides the method with the use of a Categories.  Here is an example of something one would mock with the MockInject library:
    
	//private class method
	- (void)showAlert{
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Log in Failed"
                                message:@"Username or password was incorrect"
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
    	[message show];
	}

With MockInject, using the MIMocker class, not only can you mock the initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitle init method, but you can ALSO access the same mock in your unit test for assertions, expectations, stubs, etc.  Other method swizzling solutions out there do not provide the ability to access this mock object from your test.

# Installation

Since Kiwi primarily uses CocoaPods for installation and it is a dependency of this library, MockInject is available in the CocoaPods master repo.  Follow steps -1 and 0 of the [Kiwi Wiki](https://github.com/allending/Kiwi/wiki/Getting-Started-with-Kiwi-2.0) for installation instructions for CocoaPods.

Once your project is set up with CocoaPods and Kiwi, you can add MockInject as a pod dependency to your project and run:

    pod install
in your project directory.  Here is an example of myproject's PodFile that uses Kiwi and MockInject:

    # PodFile

    platform :ios, '6.0'

    target :myprojectTests, :exclusive => true do
       pod 'Kiwi'
       pod 'MockInject'
    end
    
You can also just pull from this git repo and try to hook up the static library to your project.  Consult Apple's static library documentation for how to do this.  I couldn't get it to work, but if you're reading this, you're probably smart!

#Troubleshooting
###Memory errors when creating mocks
If you receive EXC_BAD_ACCESS errors with some of your mocks and more complicated specs, it could be due to MockInject uses ARC and Kiwi does not.  It tries to autorelease some of your stored mocks and then ARC throws an error when it tries to clean things up.  If your mock is named myMock, a workaround for this would be to add:

    CFRetain((__bridge CFTypeRef)(myMock));

after instantiating the mock.  Your project must be an ARC project to do this.


# API Documentation and Usage

### Class MIMocker
Use the static methods on this class to mock either an instance or class initializer for any ObjectiveC class.  <b>IMPORTANT:</b> Remember to use the undoMockForClass: method in the afterEach of your Kiwi test so that your classes do not remain mocked for future tests

##### methods:


<pre><code>+ (void)undoMockForClass:(Class)clazz</code></pre>

Use this method to bring your global mock for a particular class back to normal.  This should be used in the afterClass or afterEach of your Kiwi test so that future tests do not fail due to unwanted mocked dependencies.

+ clazz - The Class object for which you mocked previously and no longer wish to be mocked

<pre><code>+ (id)globalMockForClass:(Class)clazz initSelector:(SEL)initSelector</code></pre>

Use this method to override any non-static init method that takes no arguments.

+ clazz - The Class object for which you wish to override the default init method
+ initSelector - The selector for the init method with no arguments you wish to replace and return a mock.
+ returns: The same KWMock object returned for any future call of the provided initSelector.

<pre><code>+ (id)globalMockForClass:(Class)clazz initSelector:(SEL)initSelector overrideClass:(Class)overrideClass</code></pre>

Use this method to override any non-static init method that does take arguments.  The override class must contain an identical init selector to the one you wish to have mocked.

+ clazz - The Class object for which you wish to override an init method
+ initSelector - The selector for the init method you wish to replace and return a mock.
+ overrideClass - The Class object that owns the method you will replace the init method with.
+ returns: The same KWMock object returned for any future call of the provided initSelector.

<pre><code>+ (id)classMockForClass:(Class)clazz initSelector:(SEL)initSelector overrideClass:(Class)overrideClass</code></pre>

Use this method to override any STATIC init method (with or without arguments).  The override class must contain an identical init selector to the one you wish to have mocked.

+ clazz - The Class object for which you wish to override an init method
+ initSelector - The selector for the init method you wish to replace and return a mock.
+ overrideClass - The Class object that owns the method you will replace the init method with.
+ returns: The same KWMock object returned for any future call of the provided initSelector.

### Class MIMockMap
This class is needed for creating custom selectors when mocking an init method that has arguments. It contains stored mocks in an NSDictionary with a key of NSStringFromClass(class) and value = the KWMock object.

##### methods:

<pre><code>+ (void)setObject:(id)object forKey:(id<NSCopying>)aKey</code></pre>
+ object - The KWMock object to be stored
+ aKey - The Class string to store the KWMock object for (using NSStringFromClass(class))

<pre><code>+ (id)objectForKey:(id<NSCopying>)aKey</code></pre>
+ aKey - The Class string for which the KWMock object is stored (using NSStringFromClass(class))
returns: - The stored KWMock object, return this object in a custom override selector.

### Class MISwizzledMethodVO
This class should not need to be used directly, but if so, it allows for storing the mocked init method and the original init method so mocks can be undone later on.  Instances of this type are stored privately in the MIMocker to be used during undoMockForClass: method calls.

##### properties:

+ originalMethod - The <objc/runtime> Method object for the method that was overridden
+ overrideMethod - The <objc/runtime> Method object for the method that returns the KWMock.

##### methods:

<pre><code>- (id)initWithOriginalMethod:(Method)originalMethod overrideMethod:(Method)overrideMethod</code></pre>
+ originalMethod - The <objc/runtime> Method object for the method that was overridden
+ overrideMethod - The <objc/runtime> Method object for the method that returns the KWMock.
+ returns - An initialized MISwizzledMethodVO object.

# Code Examples

### Mock a non-static init method with no arguments:
Class under test:
<pre><code>
#import "MyClass.h"
#import "MyOtherClass.h"

@implementation MyClass

//public method
- (void)doSomething{
    [self delegateToMyOtherClass];
}

//private method
- (void)delegateToMyOtherClass{
    MyOtherClass *other = [[MyOtherClass alloc] init];
    [other doSomething];
}

@end
</code></pre>

Test with Mock:
<pre><code>
#import "Kiwi.h"
#import "MIMocker.h"
#import "MyClass.h"
#import "MyOtherClass.h"

SPEC_BEGIN(MyClassTest)

__block MyClass *myClass;
__block id myOtherClassMock;

describe(@"doSomething", ^{
    
    beforeEach(^{
        myClass = [[MyClass alloc] init];
        myOtherClassMock = [MIMocker globalMockForClass:[MyOtherClass class] initSelector:@selector(init)];
    });
    
    it(@"delegatesToOtherClass", ^{
        [[[myOtherClassMock should] receive] doSomething];
        [myClass doSomething];
    });
    
    afterEach(^{
        [MIMocker undoMockForClass:[MyOtherClass class]];
    });
});

SPEC_END

</code></pre>

### Mock a non-static init method that has arguments:
Class under test:
<pre><code>
#import "MyClass.h"
#import "MyOtherClass.h"

@implementation MyClass

//public method
- (void)doSomething{
    [self delegateToMyOtherClass];
}

//private method
- (void)delegateToMyOtherClass{
    MyOtherClass *other = [[MyOtherClass alloc] initWithId:@"foo"];
    [other doSomething];
}

@end
</code></pre>

Class to hold override Selectors:
<pre><code>

#import "MockSelectors.h"
#import "MIMockMap.h"
#import "Kiwi.h"

@implementation MockSelectors

- (id)initWithId:(NSString *)identifier{
	//self is actually MyOther class after this method gets Swizzled by MockInject
    id mock = [MIMockMap objectForKey:NSStringFromClass([self class])];
    //Call the method with the init params on the mock so it can be asserted later
    [mock initWithId:identifier];
    return mock;
}

@end

</code></pre>

Test with Mock:
<pre><code>
#import "Kiwi.h"
#import "MIMocker.h"
#import "MyClass.h"
#import "MyOtherClass.h"
#import "MockSelectors.h"

SPEC_BEGIN(MyClassTest)

__block MyClass *myClass;
__block id myOtherClassMock;

describe(@"doSomething", ^{
    
    beforeEach(^{
        myClass = [[MyClass alloc] init];
        myOtherClassMock = objectManagerMock = [MIMocker globalMockForClass:[MyOtherClass class] initSelector:@selector(initWithId:) overrideClass:[MockSelectors class]];
    });
    
    it(@"delegatesToOtherClass", ^{
    	[[myOtherClassMock should] receive:@selector(initWithId:) andReturn:myOtherClassMock withArguments:@"foo"];
        [[[myOtherClassMock should] receive] doSomething];
        [myClass doSomething];
    });
    
    afterEach(^{
        [MIMocker undoMockForClass:[MyOtherClass class]];
    });
});

SPEC_END

</code></pre>

### Mock a non-static init method that has arguments:
Same as the previous example, but the selector in MockSelectors should be a class method (+) and the classMockForClass:initSelector:overrideClass: method should be used on MIMocker instead.

# You want more?
This is just the surface of what can be accomplished with these types of Mocks.  Once you have a hold of the mock in your spec, you can do anything Kiwi will allow such as stubs, complex assertions, and more.  Consult the [Kiwi Wiki](https://github.com/allending/Kiwi/wiki) for more information on testing with Kiwi.  IOS developers aren't better than everyone else.  TEST YOUR CODE! You'll be glad you did.
