//
//  MainViewController.m
//  MyTwitterClient
//
//  Created by yuta_fujiwara on 2014/07/09.
//  Copyright (c) 2014年 Yuta Fujiwara. All rights reserved.
//

#import "MainViewController.h"
#import "CustomTVC.h"
#import "Tweet.h"
#import "TwitterAPI.h"
#import "PostViewController.h"
#import "AppDelegate.h"


@interface MainViewController  ()

@property (nonatomic, strong) NSMutableArray*   tweetData;
@property (nonatomic, assign) CGRect            defaultCellBodyFrame;
@property (nonatomic, assign) CGRect            defaultCellFrame;
@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView* ai ;
@property (nonatomic, strong) PostViewController* postViewController;
@property (nonatomic, strong) TwitterAPI* twitterApi;

@property (nonatomic, assign) BOOL isInitialized;

@end

@implementation MainViewController
// TODO: synthesizeの意味を理解する。
//@synthesize isLoading;

#pragma mark - Consts

static NSString* const _cellId = @"CustomTVC";

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isInitialized = NO;
    
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    if([self.navigationController isEqual:appDelegate.navigationController])=>YESを返す

//TableViewの追加と設定
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(CustomTVC.class) bundle:nil]
         forCellReuseIdentifier:_cellId];
    
//TableViewのCellの登録と設定
//    id型のもので型が確定するものはその型にしておく
    CustomTVC* customTVC = [self.tableView dequeueReusableCellWithIdentifier:_cellId];
    self.defaultCellBodyFrame = customTVC.body.frame;
    self.defaultCellFrame = customTVC.frame;
    
    [self.tableView addSubview:self.refreshControl];

//  NavigationBarの設定　（更新中に表示するアイコン）
    self.title = [NSString stringWithFormat:@"%@:%d", NSStringFromClass(self.class), [self.navigationController.viewControllers indexOfObject:self]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"投稿" style:UIBarButtonItemStylePlain  target:self action:@selector(leftBarBtnPushed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"削除" style:UIBarButtonItemStylePlain  target:self action:@selector(rightBarBtnPushed:)];
// 確認事項   [self.btn addTarget:self action:@selector(btnPushed) forControlEvents:UIControlEventTouchDown];
//    [self.tableView addSubview:self.btn];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isInitialized = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Delegate

#pragma mark  PostViewController

-(void) postViewController:(PostViewController *)postViewController postedTweet:(Tweet*)tweet
{
    DLog("________ツイート内容(引数:tweet)をTableViewに挿入する");
    [self.tweetData insertObject:tweet atIndex:0];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:0];//先頭に追加
    // インサート 指定したIndexPathの要素に対してだけデリゲートが呼ばれる
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // アップデート
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark TwitterAPIDelegate

//TwitterAPI.mから,取得時に呼び出される.ツイート配列を引数とするデリゲートメソッド,
-(void)twitterAPI:(TwitterAPI *)twitterAPI tweetData:(NSArray *)tweetData
{
    DLog(@"tweetData:\n%@", tweetData);
    
    self.isLoading = NO;
    [self.refreshControl endRefreshing];
    
    [self.tweetData addObjectsFromArray:tweetData.mutableCopy];
    [self.tableView reloadData];
}

-(void)twitterAPI:(TwitterAPI *)twitterAPI errorAtLoadData:(NSError *)error
{
    DLog(@"error:\n%@", error);
    self.isLoading = NO;
    [self.refreshControl endRefreshing];
}

#pragma mark UITableViewDataSource

//TableViewがReloadされたときに呼び出される.Tableの要素数を返す.
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    DLog("\n NUMBER OF ROW IN");
    return self.tweetData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   DLog("\n CELL FOR ROW INDEX PATH");
    CustomTVC* cell = [tableView dequeueReusableCellWithIdentifier:_cellId];
    
    Tweet* tweet = self.tweetData[indexPath.row];
    cell.body.text = [NSString stringWithFormat:@"%@", tweet.body];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.sampleData[indexPath.row]];
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 0;
    
    cell.body.frame = CGRectMake(
                                 cell.body.frame.origin.x,
                                 cell.body.frame.origin.y,
                                 cell.body.frame.size.width,
                                 cell.frame.size.height
                                 );
    [cell.body sizeToFit];
    /*
    DLog(
         @"%d"
         @"\n\tcell.body.text      :%@"
         @"\n\tcell.frame          :%@"
         @"\n\tcell.body.frame     :%@"
         @"\n\tdefaultCellBodyFrame:%@"
         , indexPath.row
         , cell.body.text
         , NSStringFromCGRect(cell.frame)
         , NSStringFromCGRect(cell.body.frame)
         , NSStringFromCGRect(self.defaultCellBodyFrame)
         );
     */
    
    return cell;
}



#pragma mark UITableViewDelegate

//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50.0;
//}
//
//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] init];
//   
//    
//    //[ai startAnimating];
//    
//    return view;
//}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    [view addSubview:self.ai];
    return view;
}

-(CGFloat)    tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog("HEIGHT FOR ROW AT INDEX PATH");
    Tweet* tweet = self.tweetData[indexPath.row];
    NSString* body = tweet.body;
    UIFont*   font = ((CustomTVC*)[self.tableView dequeueReusableCellWithIdentifier:_cellId]).body.font;
    
    CGFloat cellBodyH = [body boundingRectWithSize:CGSizeMake(self.defaultCellBodyFrame.size.width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName:font}
                                           context:nil
                         ].size.height;
    CGFloat cellH = self.defaultCellFrame.size.height + (cellBodyH - self.defaultCellBodyFrame.size.height);
    /*
    DLog(
         @"\n\tbody                :%@"
         @"\n\tdefaultCellFrame    :%@"
         @"\n\tdefaultCellBodyFrame:%@"
         @"\n\tcellBodyH           :%f"
         @"\n\tcellH               :%f"
         , body
         , NSStringFromCGRect(self.defaultCellFrame)
         , NSStringFromCGRect(self.defaultCellBodyFrame)
         , cellBodyH
         , cellH
         );
     */
    return cellH < self.defaultCellFrame.size.height ? self.defaultCellFrame.size.height : cellH;
//三項演算子構文↑↑
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    DLog(@"scrolling....\n\tpoint:%@", NSStringFromCGPoint(scrollView.contentOffset));
    CGSize  contentSize   = self.tableView.contentSize;
    CGPoint contentOffset = self.tableView.contentOffset;
    
    CGFloat remain = contentSize.height - contentOffset.y;
    
    if(remain < self.tableView.frame.size.height * 1 && self.isLoading == NO && self.isInitialized)
    {
        self.isLoading = YES;
        
        Tweet* lastTweet = self.tweetData.lastObject;
        
        //[self _requestTweets:lastTweet.id];
//        TwitterAPI* tweetApi= [[TwitterAPI alloc] init];
        CLLocationCoordinate2D OsakaEki = CLLocationCoordinate2DMake(34.701909, 135.494977);
        DLog(@"lastTweet.id:%llu", lastTweet.id);
        DLog(@"self.twieetApi:%@", self.twitterApi);
        [self.twitterApi tweetsInNeighborWithCoordinate:OsakaEki radius:1 count:30 maxId:lastTweet.id];
        
        
    }

}

#pragma mark - Event


-(void) _refreshData:(UIRefreshControl *) refreshControl
{
    DLog("REFRESH");
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    
    [self.tweetData removeAllObjects];
    [self.tableView reloadData];
    
    //[self _requestTweets:0];
    
    CLLocationCoordinate2D OsakaEki = CLLocationCoordinate2DMake(34.701909, 135.494977);
    
    [self.twitterApi tweetsInNeighborWithCoordinate:OsakaEki radius:10.0 count:30 maxId:0];

    // [self.tweetData addObjectsFromArray:tmpTWar];
}

-(void) _refresh
{
    [self.tableView reloadData];
    if (self.refreshControl.refreshing == NO) {
        [self.refreshControl endRefreshing];
    }
//    
//    for (Tweet* tweet in self.tweetData) {
//        printf("_REFRESH_CALLED_%d: %llu\n", [self.tweetData indexOfObject:tweet], tweet.id);// [[tweet.body substringToIndex:5] UTF8String]);
//    }
}

-(IBAction) rightBarBtnPushed:(id)sender
{
    DLog("\n右上のボタンが押されました.");
}
-(IBAction)leftBarBtnPushed:(id)sender
{
    DLog("\n左上のボタンが押されました.");
    [self presentViewController:self.postViewController animated:YES completion:nil];
//    [postView helloPostDel];
    
}
//- (void)_requestTweets:(unsigned long long)maxId
//{
//    printf("RequestTweet_Called %ld ¥n",(long)maxId);
////TwitterAPI
//    
//    
//    if (self.isLoading == YES) {
////        [self.ai startAnimating];
//        return;
//    }
//    self.isLoading = YES;
//    [self.ai startAnimating];
////    Twiitter
////    DLog(@"NSThred isMainThread:%@", [NSThread isMainThread] ? @"YES" : @"NO");
//
//    ACAccountType* accountType = [self.accountStore
//                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    
//    [self.accountStore
//     requestAccessToAccountsWithType:accountType
//     options:NULL
//     completion:^void (BOOL granted, NSError* error)
//     {
//         // アカウント取得失敗時
//         if (error) {
//             DLog(@"error :%@", error);
//             
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 [self.refreshControl endRefreshing];
//             });
//             
//             return;
//         }
//         
//         // titterアカウント取得（複数あるかも。。）
//         NSArray* accounts = [self.accountStore accountsWithAccountType:accountType];
//         if (accounts.count == 0) {
//             DLog(@"account 0");
//             
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 [self.refreshControl endRefreshing];
//             });
//             
//             return;
//         }
//         
//         
//         // リクエストを出すAPIを指定
//         NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
////         [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
//         // リクエストのパラメータを設定
//         NSMutableDictionary* params = @{
////                                  @"screen_name" : [accounts.firstObject username],
//                                  @"count"       : @(3).description,
//                                  @"q"           : @"",
//                                  @"geocode"     : @"34.701909,135.494977,1km"
//                                  }.mutableCopy;
//         // ロードモア時に使用
//         if (maxId != 0) {
//             [params setObject:@(maxId - 1).description forKey:@"max_id"];
//         }
//         
//         // リクエストを作成
//         SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
//                                                 requestMethod:SLRequestMethodGET
//                                                           URL:url
//                                                    parameters:params];
//         // 1つ目のアカウントを指定
//         request.account = accounts.firstObject;
//         
//         // リクエストを投げる
//         [request
//          performRequestWithHandler:^ void
//          (NSData* responseData,
//           NSHTTPURLResponse* urlResponse,
//           NSError* error)
//          {
//              self.isLoading = YES;
//              [self.ai startAnimating];
//              dispatch_async(dispatch_get_main_queue(), ^{
//                  [self.refreshControl endRefreshing];
//              });
//
////              DLog(@"responsData\n%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
//              
//              // エラー処理
//              if (error) {
//                  self.isLoading = NO;
//                  [self.ai stopAnimating];
//                  DLog(@"urlResponse:%@, error:%@", urlResponse, error);
//                  return;
//              }
//              
//              // 通信成功時(200系)
//              if (200 <= urlResponse.statusCode && urlResponse.statusCode < 300) {
//                  DLog(@"通信成功時(200系)");
//                  NSError* e = nil;
//                  NSDictionary* jsonDic = [NSJSONSerialization
//                                           JSONObjectWithData:responseData
//                                           options:NSJSONReadingAllowFragments
//                                           error:&e
//                                           ];
//                  // エラー処理
//                  if (e) {
//                      DLog(@"e:%@", e);
//                      self.isLoading = NO;
//                      [self.ai stopAnimating];
//                      return;
//                  }
//                  
//                  // データ取得成功時
//                  if (jsonDic.count > 0) {
//                      
//                      self.isLoading = NO;
//                      [self.ai stopAnimating];
//                      /*
//                       NSDictionary* jsonDic;
//                       jsonDic[@"apple"]
//                       jsonDic objectForKey:@"apple"]
//                       */
//                      
//                      
//                      
//                      
//                      // 見つかったツイート配列を格納
//                      NSArray* twAr = jsonDic[@"statuses"];
//                      
//                      // ツイート配列からテキストのみを抽出
//                      //ツイート内容,緯度経度,IDを取得
//                      
//                      for(int index = 0; index < [twAr count]; index++)
//                      {
//                          NSDictionary* status = [twAr objectAtIndex:index];
//                          Tweet* tweet = [Tweet tweetWithDic:status];
//
//                        //  tweet.latitude
////                          DLog(@"body:%@",tweet.body);
////                          DLog(@"profileImageUrl:%@",tweet.profileImageUrl);
////                          DLog(@"lati %f , long%f",tweet.latitude,tweet.longitude);
//                          
//                          [self.tweetData addObject:tweet];
//                      }
//                      
//                      // メインスレッドで実行(GCD)
//                      dispatch_async(dispatch_get_main_queue(), ^{
//                          [self _refresh];
//                      });
//                      
//                      // メインスレッドで実行(NSThread)
////                      [self performSelectorOnMainThread:@selector(_refresh)
////                                             withObject:nil
////                                          waitUntilDone:NO];
//                      
//                      /*
//                       Tweet
//                       id
//                       user.profile_image_url
//                       text
//                       geo.coordinates
//                       */
//                      
//                      /*
//                       34.683015999977,135.477230003533
//                       34.683015999977,135.527178003877
//                       34.7177310034282,135.527178003877
//                       34.7177310034282,135.477230003533
//                       */
////                      DLog(@"jsonArr:\n%@", jsonDic);
//                  }
//                  else {
//                      DLog(@"json なし");
//                  }
//              }
//              // 通信失敗時
//              else {
//                  DLog(@"request error:%@", urlResponse);
//                  self.isLoading = NO;
//                  [self.ai stopAnimating];
//              }
//              
//              self.isLoading = NO;
//              [self.ai stopAnimating];
//          }];
//     }];
//    //
//    
//}
//
#pragma mark - Accessor
-(PostViewController *) postViewController
{
    
    if(_postViewController == nil)
    {
        _postViewController = [[PostViewController alloc] init];
        _postViewController.delegate = self;
    }
    
    return _postViewController;
}

-(TwitterAPI *)twitterApi
{
    if(_twitterApi == nil)
    {
        _twitterApi = [[TwitterAPI alloc] init];
        //デリゲートを使う場合は必ず必要
        _twitterApi.delegate = self;
    }
    return _twitterApi;
}

- (NSMutableArray *) tweetData
{
    if(_tweetData == nil)
    {
        _tweetData = @[].mutableCopy;
        
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* path = [bundle pathForResource:@"sampleData" ofType:@"plist"];
        NSArray* sampleData = [NSMutableArray arrayWithContentsOfFile:path];
        
        for (NSString* tmpSampleData in sampleData) {
            Tweet* tweet =[[Tweet alloc] init];
            tweet.body = tmpSampleData;
            [_tweetData addObject:tweet];
        }
    }
    
    return _tweetData;
}

-(UIRefreshControl *)refreshControl
{
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self
                            action:@selector(_refreshData:)
                  forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
}

-(UIActivityIndicatorView*) ai
{
//TODO:[位置の調整]
//    CGFloat h = self.view.frame.size.height;
//    CGFloat w = self.view.frame.size.width;
//    self.ai.frame = CGRectMake(w/2,h,0,30);

    if(_ai == nil){
        _ai =[[UIActivityIndicatorView alloc] init];
        _ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _ai.hidesWhenStopped = NO;//ActivityIndicatorを残すとき
        
            }
    
    return _ai;
}

//-(BOOL)isLoading
//{
////更新中にUIActivityIndicatorViewのアニメーションをスタートさせる.
//    if(_isLoading == YES){
//        
//        //DLog("StartAi");
//        //[self.ai startAnimating];
//    }
//    else{
//        DLog("StopAi");
//        [self.ai stopAnimating];
//    }
//    return _isLoading;
//}


@end
