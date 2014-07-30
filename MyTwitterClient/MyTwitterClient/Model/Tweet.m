//
//  Tweet.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/15.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "Tweet.h"
#import <CoreLocation/CoreLocation.h>

@implementation Tweet


+(instancetype) tweetWithDic:(NSDictionary*)dic
{
    Tweet* tweet = [[Tweet alloc] init];
    //allKeys Dictionary が持つ全ての値を取得
    if ([dic.allKeys containsObject:@"id"])
    {
        tweet.id = [dic[@"id"] unsignedLongLongValue];
    }
    
    if ([dic.allKeys containsObject:@"text"])
    {
        tweet.body = dic[@"text"];
    }
    
    if ([dic.allKeys containsObject:@"user"])
    {
        NSDictionary* userDic = dic[@"user"];
        
        if([userDic.allKeys containsObject:@"screen_name"])
        {
            tweet.accountName = userDic[@"screen_name"];
        }
        
        
        if (
            [userDic.allKeys containsObject:@"profile_image_url"]
            && userDic[@"profile_image_url"]
            && ![userDic[@"profile_image_url"] isEqual:[NSNull null]]
            )
        {
            tweet.profileImageUrl = userDic[@"profile_image_url"];

            __weak Tweet* weakTweet = tweet;
//            別スレッドで非同期実行
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
            {
                if (weakTweet == nil) {
                    return ;
                }
                
                NSData* profileImageData = [NSData dataWithContentsOfURL:
                                            [NSURL URLWithString:weakTweet.profileImageUrl]];
                weakTweet.profileImage = [UIImage imageWithData:profileImageData];
            });
        }
    }
    
    if ([dic.allKeys containsObject:@"geo"])
    {
        NSDictionary* geoDic = dic[@"geo"];
        if ([[NSNull null] isEqual:geoDic] == NO)
        {
            if ([geoDic.allKeys containsObject:@"coordinates"])
            {
                NSArray* coorinates = geoDic[@"coordinates"];
                if (coorinates.count == 2)
                {
                    tweet.latitude = [[coorinates objectAtIndex:0] floatValue];
                    tweet.longitude = [[coorinates objectAtIndex:1] floatValue];
//(緯度，経度)　=> 住所
                    CLLocation* location =[[CLLocation alloc] initWithLatitude:tweet.latitude longitude:tweet.longitude];
                    CLGeocoder* clg = [[CLGeocoder alloc] init];

//緯度経度から住所の情報を取得するところが非同期でメインスレッド
//住所をTweet型に格納するところは非同期で別スレッド　Cellに反映されるまで、時間がかかる
//
                    DLog("MainThread:%hhd",[NSThread isMainThread]);//Main
                    [clg reverseGeocodeLocation:(CLLocation *)location
                              completionHandler:^(NSArray* placemarks, NSError* error)
                     {
                         DLog("MainThread:%hhd",[NSThread isMainThread]);//Main
//                         DLog(@"count:%d obj:%@", placemarks.count, placemarks[0]);
                         for (CLPlacemark *placemark in placemarks)
                         {
                             // それぞれの結果（場所）の情報
                             NSMutableString* address = [NSMutableString stringWithFormat:@""];
                             [address appendString:@""];
                             BOOL isStateNull = ([placemark.addressDictionary[@"State"] length] ==0)     ? YES : NO;
                             BOOL isLocalNull = ([placemark.locality length] ==0)                        ? YES : NO;
                             BOOL isThoroNull = ([placemark.thoroughfare length] ==0)                    ? YES : NO;
                             BOOL isSubThoroNull = ([placemark.subThoroughfare length] ==0)              ? YES : NO;
                            
                             DLog(@"\n\t%@\n",tweet.body);
                             DLog(@"locality        : %@ BOOL : %hhd", placemark.locality,isLocalNull);
                             
                             DLog(@"state           : %@ BOOL : %hhd", placemark.addressDictionary[@"State"],isThoroNull);
                                [address appendString:
                                 (isStateNull)? @"":placemark.addressDictionary[@"State"]];
                            
                             DLog(@"thoroughfare    : %@ BOOL : %hhd", placemark.locality,isThoroNull);
                                [address appendString:
                                 (isStateNull || isLocalNull)? @"":placemark.locality];
                             
                             DLog(@"thoroughfare    : %@ BOOL : %hhd", placemark.thoroughfare,isThoroNull);
                                [address appendString:
                                 (isStateNull || isLocalNull || isThoroNull)? @"":placemark.thoroughfare];
                             
                             DLog(@"subThoroughfare : %@ BOOL : %hhd", placemark.subThoroughfare,isSubThoroNull);
                                [address appendString:
                                 (isStateNull || isLocalNull || isThoroNull || isSubThoroNull)? @"":placemark.subThoroughfare];

                             
                             DLog(@"ERROR:%@",error.domain);
                             DLog("MainThread:%hhd",[NSThread isMainThread]);
//                             DLog("\n\tAddress      : %@", address);
                             __weak Tweet* wt =tweet;
                             //非同期で別スレッドで処理
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void)
                             {
                                 DLog("MainThread:%hhd",[NSThread isMainThread]);
                                 wt.address = address;
                             });
                             
                             
                         }
                     }];
                }
                
            }
            
        }
    }

    return tweet;
}

#pragma mark - Accessor


@end
