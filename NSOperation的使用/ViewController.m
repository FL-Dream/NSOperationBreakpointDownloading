//
//  ViewController.m
//  NSOperation的使用
//
//  Created by 周君 on 16/10/18.
//  Copyright © 2016年 周君. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/** 设置一个全局的操作队列*/
@property (nonatomic, strong) NSOperationQueue *queue;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self OperationQueue];
}

/*
 * NSOperation是一个抽象类，不能直接用，直接供开发者用的有两种
 * 1.NSBlockOperation
 * 2.NSInvocationOperation
 * 3.开发者可以继承NSOperation自定义任务
 */

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //调用NSBlockOperation的方法
//    [self blockOperation];
    //调用NSInvocationOperation的方法
//    [self invacationOperation];
    
    //让队列执行,如果暂停就执行，如果执行就暂停
//    if (self.queue.isSuspended)
//    {
//        self.queue.suspended = NO;
//    }
//    else
//    {
//        self.queue.suspended =YES;
//    }
    //取消所有操作
//    [self.queue cancelAllOperations];
    //依赖操作
    [self operationWithDependency];
    
}

//NSBlockOperation的使用比较方便的使用
- (void)blockOperation
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        //只执行这一句的话在主线程执行，NSOperation对队列的掌控比较好，自动分配队列
        NSLog(@"任务1_____%@", [NSThread currentThread]);
    }];
    
    //还可以对这个操作添加额外的线程（这时候自动在子线程执行这些任务）
    [op addExecutionBlock:^{
        NSLog(@"任务2_____%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"任务3_____%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"任务4_____%@", [NSThread currentThread]);
    }];
    
    //写完任务后需要任务开始
    [op start];
}

//NSInvocationOperation的使用还是比较麻烦的一般不去使用
- (void)invacationOperation
{
    //用来执行一个方法和[self performSelector:@selector(run) withObject:nil];很像，都是在主线程执行
    NSInvocationOperation *opInvocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
    
    [opInvocation start];
}

- (void)run
{
    NSLog(@"invocationTask______%@", [NSThread currentThread]);
}


/*
 * NSOperation还可以创建队列来执行操，用最大并发操作数来设置并行或者串行队列
 * 可以向队列里面添加操作有三种
 * 1.创建NSInvocationOperation对象添加
 * 2.创建NSBlockOperation对象添加
 * 3.直接以下面这种方式添加（NSBlockOperation的简单方式）
 */
- (void)OperationQueue
{
    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //设置最大并发操作数
    /*
     * 默认值是-1，自动调配队列
     * 设置1时，就是串行队列
     * 设置>1时，就是并行队列
     */
    queue.maxConcurrentOperationCount = -1;
    
    //添加操作
    [queue addOperationWithBlock:^{
        
        NSLog(@"操作1________%@",[NSThread currentThread]);
        /*
         * NSOperationQueue 可以选择挂起队列或者恢复队列或者取消操作
         * suspended 的值决定了暂停（挂起）或者恢复
         * YES：挂起队列 NO：恢复队列
         * 调用方法 cancelAllOperations 取消所有操作
         * 取消所有操作注意：取消操作后需要把当前的操作执行完毕后，取消排在后面的操作
         */
        
        //可以用一个耗时操作来验证一下
//        for (NSInteger i = 0; i < 5000; ++i)
//        {
//            NSLog(@"操作1____%zd____%@", i, [NSThread currentThread]);
//        }
    }];
    
    [queue addOperationWithBlock:^{

        NSLog(@"操作2________%@",[NSThread currentThread]);
//        for (NSInteger i = 0; i < 5000; ++i)
//        {
//            NSLog(@"操作2____%zd____%@", i, [NSThread currentThread]);
//        }
    }];
    
    [queue addOperationWithBlock:^{
        
        NSLog(@"操作3________%@",[NSThread currentThread]);
//        for (NSInteger i = 0; i < 5000; ++i)
//        {
//            NSLog(@"操作3____%zd____%@", i, [NSThread currentThread]);
//        }
    }];
    
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"操作4________%@",[NSThread currentThread]);
    }];
    
    [blockOperation addExecutionBlock:^{
        NSLog(@"操作5________%@",[NSThread currentThread]);
    }];
    
    [queue addOperation:invocationOperation];
    [queue addOperation:blockOperation];
    
    self.queue = queue;
}

/*
 * 在一个队列中，可以设置依赖，就像GCD中的队列组，让某个操做在一个或几个操作之后进行
 */
- (void)operationWithDependency
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    __block UIImage *image1 = nil;
    // 下载图片1
    NSBlockOperation *download1 = [NSBlockOperation blockOperationWithBlock:^{
        
        // 图片的网络路径
        NSURL *url = [NSURL URLWithString:@"http://img.pconline.com.cn/images/photoblog/9/9/8/1/9981681/200910/11/1255259355826.jpg"];
        
        // 加载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 生成图片
        image1 = [UIImage imageWithData:data];
    }];
    
    __block UIImage *image2 = nil;
    // 下载图片2
    NSBlockOperation *download2 = [NSBlockOperation blockOperationWithBlock:^{
        
        // 图片的网络路径
        NSURL *url = [NSURL URLWithString:@"http://pic38.nipic.com/20140228/5571398_215900721128_2.jpg"];
        
        
        // 加载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 生成图片
        image2 = [UIImage imageWithData:data];
    }];
    
    // 合成图片
    NSBlockOperation *combine = [NSBlockOperation blockOperationWithBlock:^{
        // 开启新的图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(100, 100));
        
        // 绘制图片
        [image1 drawInRect:CGRectMake(0, 0, 50, 100)];
        image1 = nil;
        
        [image2 drawInRect:CGRectMake(50, 0, 50, 100)];
        image2 = nil;
        
        // 取得上下文中的图片
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 结束上下文
        UIGraphicsEndImageContext();
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
    }];
    //给合成的操作添加依赖
    [combine addDependency:download1];
    [combine addDependency:download2];
    
    [queue addOperation:download1];
    [queue addOperation:download2];
    [queue addOperation:combine];
}



@end
