//
//  ViewController.m
//  Multi-thread_NSOperation
//
//  Created by qq on 2017/8/31.
//  Copyright © 2017年 fangxian. All rights reserved.
//

#import "ViewController.h"
#import "MyTestOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//        [self useInvocationOperation];
//        [self useBlockOperation];
//        [self useAddExecutionBlock];
//        [self myTestOperation];
        [self operationQueue];
//        [self useCompletionBlock];
    
    //    [self highLevelTest];
//        [self highLevelTest2];
}

//MARK: 使用子类- NSInvocationOperation
- (void)useInvocationOperation {
    
    NSInvocationOperation *invocationOp = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(runLog) object:nil];
    // 调用start方法开始执行操作
    [invocationOp start];
}

//MARK: 使用子类- NSBlockOperation
- (void)useBlockOperation {
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程
        [self runLog];
    }];
    [op start];
}

//MARK: 使用 addExecutionBlock
- (void)useAddExecutionBlock {
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程
        [self runLog];
    }];
    
    // 添加额外的任务
    // 注意：只要NSBlockOperation封装的操作数 >1，就会异步执行操作
    [op addExecutionBlock:^{
        NSLog(@"2------%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"3------%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"4------%@", [NSThread currentThread]);
    }];
    
    [op start];
}

//MARK: 使用定义继承自NSOperation的子类 MyTestOperation
-(void)myTestOperation{
    
    MyTestOperation *op = [[MyTestOperation alloc]init];
    [op start];
}

// MARK: NSOperationQueue
/*
 NSOperationQueue的作用
 1.NSOperation可以调用start方法来执行任务，但默认是同步执行的
 2.如果将NSOperation添加到NSOperationQueue（操作队列）中，系统会自动异步执行NSOperation中的操作
 */
- (void)operationQueue{
    /* 两种方法
     -(void)addOperation:(NSOperation*)op;
     -(void)addOperationWithBlock:(void(^)(void))block;
     */
    
    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //2.创建操作
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [self runLog];
    }];

    //3.添加操作到队列中
    [queue addOperation:op];
    
    
    // 方法二
    //添加操作到队列中
    [queue addOperationWithBlock:^{
        [self runLog];
    }];
}

//MARK: 操作的监听completionBlock
- (void)useCompletionBlock{
    
    //创建对象，封装操作
    NSBlockOperation *operation=[NSBlockOperation blockOperationWithBlock:^{
        for (int i=0; i<10; i++) {
            NSLog(@"-operation-下载图片-%@",[NSThread currentThread]);
        }
    }];
    
    //监听操作的执行完毕
    operation.completionBlock=^{
        //.....下载图片后继续进行的操作
        NSLog(@"--接着下载第二张图片--");
    };
    
    //创建队列
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    //把任务添加到队列中（自动执行，自动开线程）
    [queue addOperation:operation];
}

#pragma mark - NSOperation高级操作1
- (void)highLevelTest {
    /**
     NSOperation 相对于 GCD 来说，增加了以下管理线程的功能：
     1.NSOperation可以添加操作依赖：保证操作的执行顺序！ --> 和GCD中将任务添加到一个串行队列中是一样的！一个串行队列会对应一条线程
     GCD 中的按顺序执行(串行队列) ---> 串行执行
     添加操作依赖之后，系统有可能串行执行保证任务的执行顺序，还有可能绿色线程同步技术，保证任务执行顺序
     */
    NSInvocationOperation *inO = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runLog) object:nil];
    NSBlockOperation *block1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block1======%@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *block2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block2======%@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *block3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block3======%@", [NSThread currentThread]);
    }];
    
    /**
     四个操作都是耗时操作，并且要求按顺序执行，操作2是UI操作
     添加操作依赖的注意点
     1.一定要在将操作添加到操作队列中之前添加操作依赖
     2.不要添加循环依赖
     优点：对于不同操作队列中的操作，操作依赖依然有效
     提示:任务添加的顺序并不能够决定执行顺序，执行的顺序取决于依赖。使用Operation的目的就是为了让开发人员不再关心线程
     */
    
    // 1.一定要在将操作添加到操作队列中之前添加操作依赖
    [block2 addDependency:block1];
    [block3 addDependency:block2];
    [inO addDependency:block3];
    // 2.不要添加循环依赖 解开注释即循环依赖了
    //    [block1 addDependency:block3];
    
    [[[NSOperationQueue alloc] init] addOperation:block1];
    [[[NSOperationQueue alloc] init] addOperation:block2];
    [[[NSOperationQueue alloc] init] addOperation:block3];
    
    [[NSOperationQueue mainQueue] addOperation:inO];
}

#pragma mark - NSOperation高级操作2
- (void)highLevelTest2 {
    /**
     NSOperation高级操作
     应用场景：提高用户体验第一，当用户操作时，取消一切跟用户当前操作无关的进程，提升流畅度
     1.添加操作依赖
     2.管理操作：重点！是操作队列的方法
     2.1暂停/恢复 取消 操作
     2.2开启合适的线程数量！（最多不超过6条）
     
     一般开发的时候，会将操作队列(queue)设置成一个全局的变量（属性）
     */
    
    NSBlockOperation *block1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---------");
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperationWithBlock:^{
        [self runLog];
    }];
    
    [queue addOperation:block1];
    
    /*
     暂停和恢复的适用场合：如在tableview界面，开线程下载远程的网络界面，对UI会有影响，使用户体验变差。那么这种情况，就可以设置在用户操作UI（如滚动屏幕）的时候，暂停队列（不是取消队列），停止滚动的时候，恢复队列。
     */
    
    // 1.暂停操作  开始滚动的时候
    [queue setSuspended:YES];
    
    // 2.恢复操作  滑动结束的时候
    [queue setSuspended:NO];
    
    // 3.取消所有操作  接收到内存警告
    [queue cancelAllOperations];
    
    // 3.1补充：取消单个操作调用该NSOperation的cancel方法
    [block1 cancel];
    
    // 4.设置线程最大并发数，开启合适的线程数量 实例化操作队列的时候
    [queue setMaxConcurrentOperationCount:6];
    
    /**
     遇到并发编程，什么时候选择 GCD， 什么时候选择NSOperation
     1.简单的开启线程/回到主线程，选择GCD：效率更高，简单
     2.需要管理操作(考虑到用户交互！)使用NSOperation
     */
}

#pragma mark
#pragma mark - NSOperation简单操作
- (void)BaseTest {
    // 1.实例化操作对象
    NSBlockOperation *blockOperation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation1---------%@", [NSThread currentThread]);
    }];
    
    // 往当前操作中追加操作
    [blockOperation1 addExecutionBlock:^{
        NSLog(@"addblockOperation1.1-----%@", [NSThread currentThread]);
    }];
    
    [blockOperation1 addExecutionBlock:^{
        NSLog(@"addblockOperation1.2-----%@", [NSThread currentThread]);
    }];
    
    /**
     当 NSBlockOperation中的任务数 > 1 之后，无论是将操作添加到主线程还是在主线程直接执行 start, NSBlockOperation中的任务执行顺序都不确定，执行线程也不确定！
     一般在开发的时候，要避免向 NSBlockOperation 中追加任务！
     如果任务都是在子线程中执行，并且不需要保证执行顺序！可以直接追加任务
     */
    
    NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation2---------%@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *blockOperation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation3---------%@", [NSThread currentThread]);
    }];
    
    // 将操作添加到非主队列中
    //    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //
    //    [queue addOperation:blockOperation1];
    //    [queue addOperation:blockOperation2];
    //    [queue addOperation:blockOperation3];
    
    // 将操作添加到主队列中
    [[NSOperationQueue mainQueue] addOperation:blockOperation1];
    [[NSOperationQueue mainQueue] addOperation:blockOperation2];
    [[NSOperationQueue mainQueue] addOperation:blockOperation3];
}

- (void)runLog {
    NSLog(@"1------%@", [NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
