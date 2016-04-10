//
//  ViewController.m
//  04.socket访问百度
//
//  Created by 浅爱 on 16/3/2.
//  Copyright © 2016年 my. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

// 定义socke属性
@property (assign, nonatomic) int clientSocket;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    // 1.连接百度服务器  终端命令:ping www.baidu.com
    if ([self connectToServerWithIP:@"61.135.169.125" port:80]) {
        
        NSLog(@"connect succeed");
    }
    
    // 发送请求
    /** 
     格式:
     GET / HTTP/1.1
     Host: www.baidu.com
     Connection: keep-alive (可选)
     */
    NSString *sendStr = @"GET / HTTP/1.1\r\n"
    "Host: www.baidu.com\r\n"
    "Connection: close\r\n\r\n";
    
    // keep-alive
    NSString *recvStr = [self sendAndReceiveMessage:sendStr];
    
    // 得到完整的响应，分离响应体
    NSRange range = [recvStr rangeOfString:@"\r\n\r\n"];
    
    NSString *responseStr = [recvStr substringFromIndex:range.location + range.length];
    
    // 显示到webView上
    /** baseURL 指定基地址,用于给相对路径找打完整路径*/
    // 相对路径 http://www.baidu.com/1/1.jpg
    // 1/1.jpg
    [self.myWebView loadHTMLString:responseStr baseURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    
}

// 连接服务器
- (BOOL)connectToServerWithIP:(NSString *)ipStr port:(int)port {

    self.clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    struct sockaddr_in  addr;
    
    addr.sin_family = AF_INET;
    
    addr.sin_port = htons(port);
    
    addr.sin_addr.s_addr = inet_addr(ipStr.UTF8String);
    
    int connResult = connect(self.clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
    
    if (connResult == 0) {
        
        return YES;
        
    } else {
    
        return NO;
    
    }

}


// 发送并接收数据
- (NSString *)sendAndReceiveMessage:(NSString *)message {

    // 可变集合，用于分次接收服务器发送的数据
    NSMutableData *mDate = [NSMutableData data];
    
    const char *str = message.UTF8String;
    
    ssize_t sendLen = send(self.clientSocket, str, strlen(str), 0);
    
    char *buffer[1024];
    
    ssize_t recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
    
    // buffer --> data
    NSData *data = [NSData dataWithBytes:buffer length:recvLen];
    
    // 添加到集合
    [mDate appendData:data];
    
    while (recvLen != 0) {
        
        recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
        
        NSData *data = [NSData dataWithBytes:buffer length:recvLen];
        
        [mDate appendData:data];
        
    }
    
    
    // data --> NSString
    NSString *recvStr = [[NSString alloc] initWithData:mDate.copy encoding:NSUTF8StringEncoding];
    
    
    return recvStr;

}



@end






