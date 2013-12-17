//
//  SHActionSheetBlocksCallbacksScenarion.m
//  Example
//
//  Created by Seivan Heidari on 7/31/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//


#import "SHBarButtonItemBlocksSuper.h"


@interface SHBarButtonItemBlocksIntegration : SHBarButtonItemBlocksSuper
@end

@implementation SHBarButtonItemBlocksIntegration

-(void)testOneBlock; {
  __block BOOL didCallBlock = NO;
  [self.barButtonItem SH_removeAllBlocks];
  [self.barButtonItem SH_addBlock:^(UIBarButtonItem *sender) {
    didCallBlock = YES;
    XCTAssertEqualObjects(self.barButtonItem, sender);
  }];
  
  [tester tapViewWithAccessibilityLabel:self.buttonTitle];
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
  
  [tester tapViewWithAccessibilityLabel:self.buttonTitle];
  
  XCTAssertTrue(didCallFirstBlock);
  XCTAssertTrue(didCallSecondBlock);
}



@end
