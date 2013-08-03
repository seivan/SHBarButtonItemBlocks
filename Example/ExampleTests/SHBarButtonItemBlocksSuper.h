//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Seivan Heidari on 7/27/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//



#import "KIF.h"
#import "SHTestCaseAdditions.h"
#import "SHBarButtonItemBlocks.h"




@interface SHBarButtonItemBlocksSuper : KIFTestCase

@property(nonatomic,strong) UINavigationController   * navigationController;
@property(nonatomic,strong) UIBarButtonItem          * barButtonItem;
@property(nonatomic,strong) NSString                 * buttonTitle;
@property(nonatomic,copy)   SHBarButtonItemBlock       block;
@end

