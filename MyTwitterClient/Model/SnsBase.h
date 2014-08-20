//
//  SnsBase.h
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/08/12.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//各SNSの投稿で共通するデータを扱うクラス
//距離,住所,時間,
//アカウント名,投稿したテキスト,プロフィール画像

//特殊なもの
//


@interface SnsBase : NSObject<CLLocationManagerDelegate>

@property (nonatomic, assign) unsigned long long id;     // ID
///位置情報//距離関係はすべてのセルで使用する.
@property (nonatomic, assign) CGFloat   latitude;        // 緯度
@property (nonatomic, assign) CGFloat   longitude;       // 経度
//現在地と目的地との距離(m)
@property (nonatomic,assign) NSInteger distance;//meter
@property (nonatomic,strong) CLLocationManager* clMng;
@property (nonatomic,strong) CLLocation* currentLocation;
@property (nonatomic, strong) NSString* address;
///位置情報


@property (nonatomic, strong) UIImage* profileImage;
@property (nonatomic, strong) NSString* profileImageUrl; // プロフィール画像URL
@property (nonatomic, strong) NSString* accountName;     //アカウント名
@property (nonatomic,strong) NSString* postTime;//投稿時間

@property (nonatomic,strong) NSString* snsLogoImageFileName;


//テキスト
@property (nonatomic, strong) NSString* simpleBody;   // ツイート内容
@property (nonatomic, strong) NSAttributedString* attributedBody;

@property (nonatomic, strong) NSString* postImageURL; //投稿された画像URL
@property (nonatomic, strong) UIImage* postImage;


+(instancetype) getSnsDataWithDictionary:(NSDictionary*)dic;

//@property (nonatomic, strong) NSString* simpleBody;            // ツイート内容
//@property (nonatomic, strong) NSAttributedString* attributedBody;

////TODO:[ リクエスト時に引数を追加"include_entities"=>true //画像などリンクを取得できる]
//
//// プロフィール画像をダウンロードしたあとのキャッシュ
//@property (nonatomic, strong) UIImage* profileImage;

-(NSString *) _formatTimeString:(NSString*) postDateStr;

-(NSInteger) _distanceWithLatitude:(CGFloat) latitude
                         Longitude:(CGFloat) longitude;

+(CLLocation *) getCurrentLocation;

+(void) setCurrentLocation:(CLLocation*)cl;

@end
