//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Seivan Heidari on 7/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//


#import "SHBarButtonItemBlocksSuper.h"

@interface SHBarButtonItemBlocksCallbacks : SHBarButtonItemBlocksSuper

@end




@implementation SHBarButtonItemBlocksCallbacks

-(void)setUp; {
  [super setUp];

  
  
}

-(void)tearDown; {
  [super tearDown];
}

-(void)testOneBlock; {
  __block BOOL didCallBlock = NO;
  [self.barButtonItem SH_removeAllBlocks];
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {
    didCallBlock = YES;
  }];
  
  XCTAssertFalse(self.barButtonItem.SH_blocks.count == 0);
  self.block = [self.barButtonItem.SH_blocks anyObject];
  self.block(self.barButtonItem);
  XCTAssertTrue(didCallBlock);
}

-(void)testTwoBlocks; {
  __block BOOL didCallFirstBlock = NO;
  __block BOOL didCallSecondBlock = NO;
  [self.barButtonItem SH_removeAllBlocks];
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {
    didCallFirstBlock = YES;
    XCTAssertEqualObjects(self.barButtonItem, sender);
  }];
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {
    didCallSecondBlock = YES;
    XCTAssertEqualObjects(self.barButtonItem, sender);
  }];
  
  XCTAssertFalse(self.barButtonItem.SH_blocks.count == 0);
  NSArray * blocks = [self.barButtonItem.SH_blocks allObjects];
  self.block = blocks.firstObject;
  self.block(self.barButtonItem);
  self.block = blocks.lastObject;
  self.block(self.barButtonItem);
  XCTAssertTrue(didCallFirstBlock);
  XCTAssertTrue(didCallSecondBlock);
}


@end
