//
//  ViewController.m
//  zuijian
//
//  Created by momo on 9/1/13.
//  Copyright (c) 2013 momo. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

SystemSoundID soundID;


@interface ViewController ()
@property (retain, nonatomic) IBOutlet UILabel *status;
@property (retain, nonatomic) IBOutlet UITextField *host;
@property (retain, nonatomic) IBOutlet UITextField *port;
@property (retain, nonatomic) IBOutlet UILabel *speed;
@property (retain, nonatomic) AsyncUdpSocket *socket;

@end

@implementation ViewController
@synthesize status;
@synthesize host;
@synthesize port;
@synthesize speed;
@synthesize socket;

- (IBAction)buttonPressed:(id)sender {
    NSArray *commandArray;
    commandArray = [NSArray arrayWithObjects:
                    @"Step",@"SpeedUp",@"Keep1",@"Ergent",@"Keep2",@"SlowDown",nil];
    
    NSString *command = [commandArray objectAtIndex:[sender tag]];
    NSString *sound = [commandArray objectAtIndex:[sender tag]];
    
    [self playSound:sound :@"wav"];
    
    //NSString *response  = [NSString stringWithFormat:@"msg:%@", command];
    NSData *data = [[NSData alloc] initWithData:[command dataUsingEncoding:NSASCIIStringEncoding]];
	[socket sendData:data toHost:host.text port:[port.text integerValue] withTimeout:-1 tag:1];
}

- (IBAction)connectPressed:(UIButton *)sender {
    
    //[speed setText:@"hi"];
    
    NSLog(@"host is:%@, port is:%@, label is:%@",host.text,port.text,speed);
    
    host.hidden = YES;
    port.hidden = YES;
    
    //NSString *response  = [NSString stringWithFormat:@"msg:%@", command];
	NSData *data = [[NSData alloc] initWithData:[@"Start" dataUsingEncoding:NSASCIIStringEncoding]];
	[socket sendData:data toHost:host.text port:[port.text integerValue] withTimeout:-1 tag:1];
    
}
- (IBAction)stopPressed:(id)sender {
    host.hidden = NO;
    port.hidden = NO;
    
    //NSString *response  = [NSString stringWithFormat:@"msg:%@", command];
	NSData *data = [[NSData alloc] initWithData:[@"Stop" dataUsingEncoding:NSASCIIStringEncoding]];
	[socket sendData:data toHost:host.text port:[port.text integerValue] withTimeout:-1 tag:1];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[socket receiveWithTimeout:-1 tag:1];
    NSString *head = [msg substringToIndex:1];
    NSString *content = [msg substringFromIndex:1];
    NSLog(@"received data: %@,%@",head,content);
    NSDictionary *mapping = [NSDictionary  dictionaryWithObjectsAndKeys :
                             @"步进区",@"Step" , @"加速区",@"SpeedUp" ,
                             @"左侧保持区",@"Keep1" , @"急刹急启区",@"Ergent" ,
                             @"右侧保持区",@"Keep2" , @"减速区",@"SlowDown" , nil];
    if ([head isEqualToString:@"V"]) {
        self.speed.text = content;
    }else{
        self.status.text = [mapping objectForKey:msg];
    }
    
    //now that only switch on udp package is needed to finish this program.
    
	return YES;
}

-(void) playSound : (NSString *) fName : (NSString *) ext
{
    NSString *path  = [[NSBundle mainBundle] pathForResource:fName ofType:ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AudioServicesCreateSystemSoundID((CFURLRef) pathURL, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    else
    {
        NSLog(@"error, file not found: %@", path);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.host.text = @"127.0.0.1";
    //self.host.text = @"192.168.1.2";
    //self.host.text = @"localhost";
    self.port.text = @"31500";
    
    socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [socket bindToPort:18000 error:nil];
    socket.maxReceiveBufferSize = 5;
    [socket receiveWithTimeout:-1 tag:1];
}

- (void)viewDidUnload
{
    [self setStatus:nil];
    [self setHost:nil];
    [self setPort:nil];
    [self setSpeed:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
