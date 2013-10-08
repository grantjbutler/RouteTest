//
//  GJBAppDelegate.m
//  RouteTest
//
//  Created by Grant Butler on 10/7/13.
//  Copyright (c) 2013 Grant Butler. All rights reserved.
//

#import "GJBAppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface GJBAppDelegate () <NSNetServiceBrowserDelegate>

@property (nonatomic) NSNetServiceBrowser *browser;
@property (nonatomic) NSMutableArray *netServices;
@property (nonatomic) MPMoviePlayerViewController *moviePlayerViewController;

@end

@implementation GJBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.netServices = [[NSMutableArray alloc] init];
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.delegate = self;
    [self.browser searchForServicesOfType:@"_airplay._tcp" inDomain:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    self.moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/104161/Music/Good%20Girl%20Remix.mp3"]];
    self.window.rootViewController = self.moviePlayerViewController;
    
    return YES;
}

- (void)routeChanged:(NSNotification *)notification {
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    AVAudioSessionPortDescription *airplayPort = nil;
    
    for (AVAudioSessionPortDescription *port in [currentRoute outputs]) {
        if ([[port portType] isEqualToString:AVAudioSessionPortAirPlay]) {
            airplayPort = port;
            
            break;
        }
    }
    
    if (!airplayPort) {
        return;
    }
    
    NSNetService *airplayNetService = nil;
    
    for (NSNetService *netService in self.netServices) {
        if ([netService.name isEqualToString:airplayPort.portName]) {
            airplayNetService = netService;
            
            break;
        }
    }
    
    if (!airplayNetService) {
        return;
    }
    
    NSDictionary *TXTRecord = [NSNetService dictionaryFromTXTRecordData:[airplayNetService TXTRecordData]];
    NSData *versionData = TXTRecord[@"srcvers"];
    NSString *softwareVersion = [[NSString alloc] initWithData:versionData encoding:NSUTF8StringEncoding];
    
    [self.moviePlayerViewController.moviePlayer pause];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Airplaying" message:[NSString stringWithFormat:@"You're now connected to %@, which is running version %@", airplayNetService.name, softwareVersion] delegate:nil cancelButtonTitle:@"Good to Know!" otherButtonTitles:nil];
    [alert show];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.netServices addObject:aNetService];
    [aNetService resolveWithTimeout:300]; // Really large just because.
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.netServices removeObject:aNetService];
}

@end
