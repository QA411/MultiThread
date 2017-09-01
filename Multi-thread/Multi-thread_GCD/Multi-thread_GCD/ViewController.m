//
//  ViewController.m
//  Multi-thread_GCD
//
//  Created by qq on 2017/8/29.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)clickOnAction:(id)sender {
    
        [self syncConcurrent];
    //    [self asyncConcurrent];
    
    //    [self syncSerial];
    //    [self asyncSerial];
    
    //    [self syncMain];
    //    [self asyncMain];
    
    //    dispatch_queue_t queue = dispatch_queue_create("mytest.queue", DISPATCH_QUEUE_CONCURRENT);
    //
    //    dispatch_async(queue, ^{
    //        [self syncMain];
    //    });
    
    
    
    //    // MARK:👇代码死锁 会造成死锁  原理与方法syncMain 一样
    //    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    //    void (^block)() = ^{
    //        NSLog(@"mainQueue---%@",[NSThread currentThread]);
    //    };
    //    dispatch_sync(mainQueue, block);
    ////    在上面这个例子中，主队列在执行dispatch_sync，随后队列中新增一个任务block。因为主队列是同步队列，所以block要等dispatch_sync执行完才能执行，但是dispatch_sync是同步派发，要等block执行完才算是结束。在主队列中的两个任务互相等待，导致了死锁。

}

//MARK: 并行队列 + 同步执行
- (void) syncConcurrent
{
    NSLog(@"begin-- 并行队列 + 同步执行");
    dispatch_queue_t queue= dispatch_queue_create("mytest.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"1------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"2------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"3------%@",[NSThread currentThread]);
        }
    });
    NSLog(@"end-- 并行队列 + 同步执行");
}

//MARK: 并行队列 + 异步执行
- (void) asyncConcurrent
{
    NSLog(@"begin-- 并行队列 + 异步执行");
    dispatch_queue_t queue= dispatch_queue_create("mytest.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"1------%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"2------%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"3------%@",[NSThread currentThread]);
        }
    });
    
    NSLog(@"end-- 并行队列 + 异步执行");
}

//MARK: 串行队列 + 同步执行
- (void) syncSerial
{
    NSLog(@"begin-- 串行队列 + 同步执行");
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"1------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"2------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"3------%@",[NSThread currentThread]);
        }
    });
    NSLog(@"end-- 串行队列 + 同步执行");
}

//MARK: 串行队列 + 异步执行
- (void) asyncSerial
{
    NSLog(@"begin-- 串行队列 + 异步执行");
    dispatch_queue_t queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"1------%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"2------%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"3------%@",[NSThread currentThread]);
        }
    });
    
    NSLog(@"end-- 串行队列 + 异步执行");
}

//MARK: 主队列 + 同步执行   造成死锁  main_queue正在处理syncMain  而syncMain方法中又有同步事件要处理  造成相互等待
- (void)syncMain
{
    NSLog(@"begin-- 主队列 + 同步执行");
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"1------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"2------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"3------%@",[NSThread currentThread]);
        }
    });
    NSLog(@"end-- 主队列 + 同步执行");
}

//MARK: 主队列 + 异步执行
- (void)asyncMain
{
    NSLog(@"begin-- 主队列 + 异步执行");
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"1------%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"2------%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"3------%@",[NSThread currentThread]);
        }
    });
    NSLog(@"end-- 主队列 + 异步执行");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
