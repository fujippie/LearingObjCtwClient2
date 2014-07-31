//
//  Tweet.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/15.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface Tweet : NSObject

@property (nonatomic, assign) unsigned long long id;     // ツイートID
@property (nonatomic, strong) NSString* body;            // ツイート内容
@property (nonatomic, strong) NSString* profileImageUrl; // プロフィール画像URL
@property (nonatomic, assign) CGFloat   latitude;        // 緯度
@property (nonatomic, assign) CGFloat   longitude;       // 経度
@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* accountName;     //アカウント名
//@property (nonatomic, strong) time // ツイートした時間(何分前)
@property (nonatomic, strong) NSString* tweetImageURL; //ツイッターで投稿された画像を取得
//TODO:[ リクエスト時に引数を追加"include_entities"=>true //画像などリンクを取得できる]
//現在地と目的地の距離を計算
@property (nonatomic,assign) CLLocationDistance* distance;
// プロフィール画像をダウンロードしたあとのキャッシュ
@property (nonatomic, strong) UIImage* profileImage;

//投稿してから　何分前　か
@property (nonatomic,strong) NSString* postTime;


+(instancetype) tweetWithDic:(NSDictionary*)dic;


@end
