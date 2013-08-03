//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Seivan Heidari on 7/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//


#import "SHBarButtonItemBlocksSuper.h"

@interface SHBarButtonItemBlocksSelectors : SHBarButtonItemBlocksSuper
@end



@implementation SHBarButtonItemBlocksSelectors

-(void)setUp; {
  [super setUp];    
}

-(void)tearDown; {
  [super tearDown];
}

-(void)testHasSetTarget; {
  STAssertNotNil(self.barButtonItem.target, nil);
}

-(void)testHasSetAction; {
  SEL selector = self.barButtonItem.action;
  STAssertTrue(selector != NULL, nil);
}

-(void)testSH_blocks; {
  STAssertTrue(self.barButtonItem.SH_blocks.count == 1, nil);
  STAssertEqualObjects(self.barButtonItem.SH_blocks.class, NSSet.new.class, nil);
}

-(void)testSH_addBlock; {
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {}];
  STAssertTrue(self.barButtonItem.SH_blocks.count == 2, nil);
}

-(void)testSH_removeBlock; {
  [self.barButtonItem SH_removeBlock:self.block];
  STAssertTrue(self.barButtonItem.SH_blocks.SH_isEmpty, nil);
}

-(void)testSH_removeAllBlocks; {
  [self.barButtonItem SH_removeAllBlocks];
  STAssertTrue(self.barButtonItem.SH_blocks.SH_isEmpty, nil);
  
}





@end
