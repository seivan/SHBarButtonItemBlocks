//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Seivan Heidari on 7/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//



#import "SHBarButtonItemBlocksSuper.h"

@implementation SHBarButtonItemBlocksSuper

-(void)setUp; {
  [super setUp];
  self.navigationController = [[UINavigationController alloc]
                               initWithRootViewController:UIViewController.new];
  
  self.buttonTitle = @"Special Button!";
  self.block = ^void(UIBarButtonItem * sender) {
    
  };
  self.barButtonItem = [UIBarButtonItem SH_barButtonItemWithTitle:self.buttonTitle
                                                            style:UIBarButtonItemStyleBordered withBlock:self.block];
  
  UIViewController * vc = self.navigationController.viewControllers.firstObject;
  vc.navigationItem.rightBarButtonItem = self.barButtonItem;
  [UIApplication sharedApplication].keyWindow.rootViewController = self.navigationController;
  
}
@end

