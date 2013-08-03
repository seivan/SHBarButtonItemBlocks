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
  
  STAssertFalse(self.barButtonItem.SH_blocks.SH_isEmpty, nil);
  self.block = self.barButtonItem.SH_blocks.SH_toArray.SH_firstObject;
  self.block(self.barButtonItem);
  STAssertTrue(didCallBlock, nil);
}

-(void)testTwoBlocks; {
  __block BOOL didCallFirstBlock = NO;
  __block BOOL didCallSecondBlock = NO;
  [self.barButtonItem SH_removeAllBlocks];
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {
    didCallFirstBlock = YES;
    STAssertEqualObjects(self.barButtonItem, sender, nil);
  }];
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {
    didCallSecondBlock = YES;
    STAssertEqualObjects(self.barButtonItem, sender, nil);
  }];
  
  STAssertFalse(self.barButtonItem.SH_blocks.SH_isEmpty, nil);
  NSArray * blocks = self.barButtonItem.SH_blocks.SH_toArray;
  self.block = blocks.SH_firstObject;
  self.block(self.barButtonItem);
  self.block = blocks.SH_lastObject;
  self.block(self.barButtonItem);
  STAssertTrue(didCallFirstBlock, nil);
  STAssertTrue(didCallSecondBlock, nil);
}


@end
