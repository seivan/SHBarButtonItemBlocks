//
//  UIViewController+SHSegueBlock.m
//  Example
//
//  Created by Seivan Heidari on 5/16/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "NSObject+SHKeyValueObserverBlocks.h"
#import <objc/runtime.h>


@interface SHKeyValueObserverBlocksManager : NSObject

@property(nonatomic,strong) NSMapTable   * mapBlocks;
@property(nonatomic,strong) NSMutableSet * setOfHijackedClasses;

+(instancetype)sharedManager;
-(void)hijackDeallocForClass:(Class)theClass;
-(void)SH_memoryDebugger;
@end



@implementation SHKeyValueObserverBlocksManager
#pragma mark -
#pragma mark Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    self.mapBlocks            = [NSMapTable strongToStrongObjectsMapTable];
    self.setOfHijackedClasses = [NSMutableSet set];
    
    [self SH_memoryDebugger];
  }
  
  return self;
}

+(instancetype)sharedManager; {
  static SHKeyValueObserverBlocksManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SHKeyValueObserverBlocksManager alloc] init];
    
  });
  
  return _sharedInstance;
  
}

#pragma mark -
#pragma mark Swizzling
-(void)hijackDeallocForClass:(Class)theClass; {
  if ([self.setOfHijackedClasses containsObject:theClass] == NO) {
    
    SEL    deallocSelector               = NSSelectorFromString(@"dealloc");
    SEL    hijackedDeallocSelector       = NSSelectorFromString(@"hijackedDealloc");
    Method deallocMethod                 = class_getInstanceMethod(theClass, deallocSelector);
    Method hijackedDeallocMethod         = class_getInstanceMethod(theClass, hijackedDeallocSelector);
    
    IMP    hijackedDeallocImplementation = method_getImplementation(hijackedDeallocMethod);
    
    //merge hijackedDeallocImplementation on the deallocSelector
    class_replaceMethod(theClass,
                        deallocSelector,
                        hijackedDeallocImplementation,
                        method_getTypeEncoding(deallocMethod)
                        );
    
    
    [self.setOfHijackedClasses addObject:theClass];
  }
  
}

#pragma mark -
#pragma mark Debugger
-(void)SH_memoryDebugger; {
  double delayInSeconds = 2.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
    NSLog(@"MAP %@",self.mapBlocks);
    NSLog(@"SET %@",self.setOfHijackedClasses);
    [self SH_memoryDebugger];
  });
}


@end

@interface NSObject ()


@end

typedef NSMutableDictionary * (^SHKeyValueObserverBlockModifer)(NSMutableDictionary * keyPathMap);

@interface NSObject (SHKeyValueObserverBlocksPrivate)
-(void)setupKeyPathMapBlock:(SHKeyValueObserverBlockModifer)theBlock;
-(void)removeObserverForKeyPath:(NSString *)theKeyPath withContext:(NSString *)theContextString;
-(void)hijackedDealloc;
-(void)hijackDealloc;
@property(nonatomic,readonly) NSString               * identifier;
@property(nonatomic,readonly) NSMapTable             * mapObserverBlocks;
@property(nonatomic,readwrite) NSMutableDictionary   * mapObserverKeyPaths;

@end

static char SHKeyValueObserverBlocksContext;
@implementation NSObject (SHKeyValueObserverBlocks)

#pragma mark -
#pragma mark Create Observers



-(NSString *)SH_addObserverForKeyPaths:(id<NSFastEnumeration>)theKeyPaths
                                 block:(SHKeyValueObserverBlock)theBlock;  {
  
  return [self SH_addObserverForKeyPaths:theKeyPaths
                             withOptions:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior
                                   block:theBlock];
  
  
}


-(NSString *)SH_addObserverForKeyPaths:(id<NSFastEnumeration>)theKeyPaths
                           withOptions:(NSKeyValueObservingOptions)theOptions
                                 block:(SHKeyValueObserverBlock)theBlock; {
  [self hijackDealloc];
  
  NSString * identifier = [[NSUUID UUID] UUIDString];
  
  [self setupKeyPathMapBlock:^NSMutableDictionary *(NSMutableDictionary * keyPathMap) {
    
    for (NSString * keyPath in theKeyPaths) {
      
      NSMutableDictionary *  identifiers = keyPathMap[keyPath];
      if(identifiers == nil) identifiers = @{}.mutableCopy;
      
      NSMutableArray *  blocks = identifiers[identifier];
      if(blocks == nil) blocks = @[].mutableCopy;
      
      [blocks addObject:[theBlock copy]];
      identifiers[identifier] = blocks;
      
      keyPathMap[keyPath] = identifiers;
      [self addObserver:self forKeyPath:keyPath
                options:theOptions
                context:(__bridge void *)(identifier)];
    }
    return keyPathMap;
    
  }];
  return identifier;
  
}



#pragma mark -
#pragma mark Remove Observers


-(void)SH_removeObserversForKeyPaths:(id<NSFastEnumeration>)theKeyPaths
                     withIdentifiers:(id<NSFastEnumeration>)theIdentifiers;  {

  [self setupKeyPathMapBlock:^NSMutableDictionary *(NSMutableDictionary *keyPathMap) {
    NSMutableArray * keyPathsToRemove = @[].mutableCopy;
    for (NSString * keyPath in theKeyPaths) {
      NSMutableDictionary * identifiers =  keyPathMap[keyPath];
      
      for (NSString * identifier in theIdentifiers) {
        NSMutableArray * blocks = identifiers[identifier];
        for (SHKeyValueObserverBlock block in blocks) {
          [self removeObserverForKeyPath:keyPath withContext:identifier];
        }
        [identifiers removeObjectForKey:identifier];
      }
      if(identifiers.count < 1)
        [keyPathsToRemove addObject:keyPath];
    }
    [keyPathMap removeObjectsForKeys:keyPathsToRemove];

    return keyPathMap;
  }];

}


-(void)SH_removeObserversWithIdentifiers:(id<NSFastEnumeration>)theIdentifiers; {
  
  [self setupKeyPathMapBlock:^NSMutableDictionary *(NSMutableDictionary * keyPathMap) {
    
    NSMutableArray * keyPathsToRemove = @[].mutableCopy;
    for (NSString * identifierToRemove in theIdentifiers) {
      for (NSString * keyPath in keyPathMap) {
        NSMutableDictionary * identifiers = keyPathMap[keyPath];
        [identifiers removeObjectForKey:identifierToRemove];
        [self removeObserverForKeyPath:keyPath withContext:identifierToRemove];
        if(identifiers.count < 1)
          [keyPathsToRemove addObject:keyPath];
      }
      
    }
    [keyPathMap removeObjectsForKeys:keyPathsToRemove];
    return keyPathMap;
    
  }];
  

  
}

-(void)SH_removeObserversForKeyPaths:(id<NSFastEnumeration>)theKeyPaths; {
  [self setupKeyPathMapBlock:^NSMutableDictionary *(NSMutableDictionary * keyPathMap) {
    for (NSString * keyPath in theKeyPaths) {
      NSMutableDictionary * identifiers =  keyPathMap[keyPath];
      
      for (NSString * identifier in identifiers.allKeys)
        [self removeObserverForKeyPath:keyPath withContext:identifier];

      [keyPathMap removeObjectForKey:keyPath];
      
      
    }
    return keyPathMap;
  }];  
}

-(void)SH_removeAllObservers; {
  self.mapObserverKeyPaths = nil;
}


#pragma mark -
#pragma mark Privates

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Getters
-(NSMutableDictionary *)mapObserverKeyPaths; {
  NSMutableDictionary * mapObserverKeyPaths = [self.mapObserverBlocks objectForKey:self.identifier];
  if(mapObserverKeyPaths == nil) {
    mapObserverKeyPaths = @{}.mutableCopy;
  }
  
  return mapObserverKeyPaths;
}

#pragma mark -
#pragma mark Setters
-(void)setMapObserverKeyPaths:(NSMutableDictionary *)mapObserverKeypaths; {
  if(mapObserverKeypaths.count > 0)
    [self.mapObserverBlocks setObject:mapObserverKeypaths forKey:self.identifier];
  else if(self.mapObserverKeyPaths.count > 0) {
    [self SH_removeObserversForKeyPaths:self.mapObserverKeyPaths.allKeys];
  }
  else
    [self.mapObserverBlocks removeObjectForKey:self.identifier];
  
  
}



#pragma mark -
#pragma mark Helpers
-(void)setupKeyPathMapBlock:(SHKeyValueObserverBlockModifer)theBlock; {
  NSMutableDictionary * keyPaths = theBlock(self.mapObserverKeyPaths);
  self.mapObserverKeyPaths = keyPaths;
  
}
-(void)removeObserverForKeyPath:(NSString *)theKeyPath withContext:(NSString *)theContextString; {
  [self removeObserver:self forKeyPath:theKeyPath context:(__bridge void *)(theContextString)];
}

static char kDisgustingSwizzledVariableKey;
-(NSString *)identifier; {
  NSString * _identifier = objc_getAssociatedObject(self, kDisgustingSwizzledVariableKey);
  if(_identifier == nil) {
    _identifier = [[NSUUID UUID] UUIDString];
    objc_setAssociatedObject(self, kDisgustingSwizzledVariableKey, _identifier, OBJC_ASSOCIATION_ASSIGN);
  }
  return _identifier;
}

-(NSMapTable *)mapObserverBlocks; {
  return SHKeyValueObserverBlocksManager.sharedManager.mapBlocks;
}

#pragma mark -
#pragma mark Dealloc
-(void)hijackedDealloc; {
  [self SH_removeAllObservers];
}

-(void)hijackDealloc; {
  Class class = [self class];
  [SHKeyValueObserverBlocksManager.sharedManager hijackDeallocForClass:class];
}


#pragma mark -
#pragma mark Standard Observer
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context; {
  NSString            * contextUUID  = (__bridge NSString *)(context);
  NSMutableDictionary * identifiers  = self.mapObserverKeyPaths[keyPath];
  
  if ([identifiers objectForKey:contextUUID]) {
  
    [identifiers.allValues enumerateObjectsUsingBlock:^(NSArray * blocks, NSUInteger _, BOOL * __) {
      [blocks enumerateObjectsUsingBlock:^(SHKeyValueObserverBlock block, NSUInteger idx, BOOL *stop) {
        if(block) block(self,keyPath,change);
      }];
    }];
  }
  
  
}
#pragma clang diagnostic pop

@end
