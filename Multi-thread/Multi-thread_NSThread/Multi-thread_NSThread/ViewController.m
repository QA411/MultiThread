//
//  ViewController.m
//  Multi-thread_NSThread
//
//  Created by qq on 2017/9/1.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSInteger tickets;//剩余票数
    NSInteger sellNum;//卖出票数
    NSThread* thread1;//买票线程1
    NSThread* thread2;//买票线程2
    NSLock* theLock;//锁
}
@property (nonatomic, strong) NSThread* myThread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  
}

//（线程同步）2人抢票  抢完为止
- (IBAction)clickOnBuyTickets:(id)sender {
    
    tickets = 7;
    sellNum = 0;
    theLock = [[NSLock alloc] init];
    
    thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(buyTickets) object:nil];
    [thread1 setName:@"Thread-1"];
    [thread1 start];
    
    
    thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(buyTickets) object:nil];
    [thread2 setName:@"Thread-2"];
    [thread2 start];
}

//买票
-(void)buyTickets {
    
    // 让它一直把票售完跳出break为止
    while (TRUE) {
        //上锁
        [theLock lock];
        if(tickets >= 0){
            [NSThread sleepForTimeInterval:0.09];
            sellNum = 7 - tickets;
            NSLog(@"当前票数是:%ld,售出:%ld,线程名:%@",tickets,sellNum,[[NSThread currentThread] name]);
            tickets--;
        }else{
            break;
        }
        [theLock unlock];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
