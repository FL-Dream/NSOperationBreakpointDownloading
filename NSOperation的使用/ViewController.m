//
//  ViewController.m
//  NSOperation的使用
//
//  Created by 周君 on 16/10/18.
//  Copyright © 2016年 周君. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

/*
 * NSOperation是一个抽象类，不能直接用，直接供开发者用的有两种
 * 1.NSBlockOperation
 * 2.NSInvocationOperation
 * 3.开发者可以继承NSOperation自定义任务
 */

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //调用NSBlockOperation的方法
    [self blockOperation];
    
}

//NSBlockOperation的使用比较方便的使用
- (void)blockOperation
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        //只执行这一句的话在主线程执行，NSOperation对队列的掌控比较好
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

@end
