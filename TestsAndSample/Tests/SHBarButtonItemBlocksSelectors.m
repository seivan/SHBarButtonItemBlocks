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
  XCTAssertNotNil(self.barButtonItem.target);
}

-(void)testHasSetAction; {
  SEL selector = self.barButtonItem.action;
  XCTAssertTrue(selector != NULL);
}

-(void)testSetActionAndTargetOnAddBlock; {
  [self testSH_removeAllBlocks];
  [self.barButtonItem SH_addBlock:self.block];
  [self testHasSetTarget];
  [self testHasSetAction];
  
}

-(void)testSH_blocks; {
  XCTAssertTrue(self.barButtonItem.SH_blocks.count == 1);
  XCTAssertEqualObjects(self.barButtonItem.SH_blocks.class, NSSet.new.class);
}

-(void)testSH_addBlock; {
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {}];
  XCTAssertTrue(self.barButtonItem.SH_blocks.count == 2);
}

-(void)testSH_removeBlock; {
  [self.barButtonItem SH_removeBlock:self.block];
  XCTAssertTrue(self.barButtonItem.SH_blocks.count == 0);
}

-(void)testSH_removeAllBlocks; {
  [self.barButtonItem SH_removeAllBlocks];
  XCTAssertTrue(self.barButtonItem.SH_blocks.count == 0);
  SEL selector = self.barButtonItem.action;
  XCTAssertTrue(selector == NULL);
  XCTAssertNil(self.barButtonItem.target);

}







@end
