//
//  MyTestOperation.m
//  Multi-thread_NSOperation
//
//  Created by qq on 2017/8/31.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "MyTestOperation.h"

@implementation MyTestOperation

/**
 * 需要执行的任务 重写main方法
 */
- (void)main
{
    for (int i = 0; i < 5; ++i) {
        NSLog(@"%d-----%@",i,[NSThread currentThread]);
    }
}

@end
