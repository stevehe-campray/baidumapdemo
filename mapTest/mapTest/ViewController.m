//
//  ViewController.m
//  mapTest
//
//  Created by hejingjin on 16/7/7.
//  Copyright © 2016年 Chinahr. All rights reserved.
//

#import "ViewController.h"

//------------------------------百度---------------------------------
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#import "CLLocation+YCLocation.h"

@interface ViewController ()<BMKLocationServiceDelegate,BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate,CLLocationManagerDelegate>{

    BMKGeoCodeSearch* _geocodesearch;
    BMKLocationViewDisplayParam *_displayParam;
    
    
    BMKPolyline *polyline;
    bool isGeoSearch;
}
@property(nonatomic,strong)BMKMapView *mapView;
@property(nonatomic,strong)BMKLocationService *locService;
@property (nonatomic,strong) BMKReverseGeoCodeOption        *reverseGeocodeSearchOption;
@property(nonatomic,strong)BMKRouteSearch *searcher;


@property (nonatomic,strong)  CLLocationManager         *locationManager;
//通过经纬度得到城市名称
@property (nonatomic,strong) NSString       *coorLatitude;
@property (nonatomic,strong) NSString       *coorLongitude;
@property (nonatomic,strong)BMKWalkingRoutePlanOption *transitRouteSearchOption;


@property (nonatomic,strong)NSArray *titudearray;
@property (nonatomic,strong)NSArray *gitudearray;


@property (nonatomic,strong)NSMutableArray *animationviewarray;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
  self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _mapView.showsUserLocation = NO;//显示定位图层
//    _mapView = mapView;
   
    _animationviewarray  = [[NSMutableArray alloc] init];
   
//    self.view = mapView;
    
    _titudearray = @[@"30.542332",@"30.546300",@"30.540332"];
    _gitudearray = @[@"104.069829",@"104.069829",@"104.069829"];
    
    
    
    _searcher = [[BMKRouteSearch alloc]init];
    _searcher.delegate = self;
    //发起检索
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = @"长虹科技大厦";
    start.cityName = @"成都市";
//    start.pt = 
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = @"美年广场";
    end.cityName = @"成都市";
    BMKWalkingRoutePlanOption *transitRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
//    transitRouteSearchOption.city= @"成都市";
  
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to = end;
    _transitRouteSearchOption  = transitRouteSearchOption;
    
    //通过定位获得经纬度
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];
    
    
    //1.2其他配置
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100;
    
    // 1.3开始定位
    [_locationManager startUpdatingLocation];
    
    
    
    
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
//    [_locService startUserLocationService];
    
    
}




//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    [_mapView setZoomLevel:16];
    [_mapView updateLocationData:userLocation];
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    [_mapView updateLocationViewWithParam:_displayParam];
    
    
}

//大头针样式
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        // 设置位置
//        newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
        return newAnnotationView;
    }
    
    return nil;
}


//实现Deleage处理回调结果
//-(void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:    (BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
//{
//    if (error == BMK_SEARCH_NO_ERROR) {
//        //在此处理正常结果
//    }
//    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
//        //当路线起终点有歧义时通，获取建议检索起终点
//        //result.routeAddrResult
//    }
//    else {
//        NSLog(@"抱歉，未找到结果");
//    }
//}

// 线路规划回调

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error{

    
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
//        NSLog(@"%@",result.routes);
        BMKWalkingRouteLine *line = result.routes[0];
        NSUInteger count = line.steps.count;
        
        CLLocationCoordinate2D *coords=(CLLocationCoordinate2D *)malloc((count + 1)*sizeof(CLLocationCoordinate2D));
        
        
        NSLog(@"%@",line.steps);
        for (int i = 0; i< count; i++) {
            BMKWalkingStep *step = line.steps[i];
            NSLog(@"%@",step.instruction);
            if (i==0) {
                BMKRouteNode *start = step.entrace;
                BMKRouteNode *end = step.exit;
                coords[i] = start.location;
                coords[i+1] = end.location;
                
            }else{
                 BMKRouteNode *end = step.exit;
                coords[i+1] =end.location;
            }
        }

        polyline = [BMKPolyline polylineWithCoordinates:coords count:count+1];
        [_mapView addOverlay:polyline];
        free(coords); //释放空间
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //当路线起终点有歧义时通，获取建议检索起终点
        //result.routeAddrResult
         NSLog(@"%@",result);
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
    
   
    
}


// Override
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8];
        polylineView.lineWidth = 3.0;
        
        return polylineView;
    }
    return nil;
}

#pragma mark -- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
//        newLocation = [newLocation locationBaiduFromMars];
    
    CLLocation * location = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
  //地图坐标转火星坐标
    CLLocation * marsLoction =   [location locationMarsFromEarth];

  //火星坐标转百度地图坐标
    CLLocation *baiduLoction = [marsLoction locationBaiduFromMars];
        _coorLatitude = [NSString stringWithFormat:@"%lf",baiduLoction.coordinate.latitude];
        _coorLongitude = [NSString stringWithFormat:@"%lf",baiduLoction.coordinate.longitude];
        if (!_coorLongitude) {
            UIAlertView *aleater = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"定位失败，请查看是否打开定位" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
            [aleater show];
        }else{
            
            [self createMap];
            
        }

    
}


- (void)initializeUserInterfac
{
    //配置地图
    if (!self.mapView) {
        self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    }
    _mapView.delegate = self;
    

//    _mapView.rotateEnabled = NO;
    
    BMKLocationViewDisplayParam* displayParam = [[BMKLocationViewDisplayParam alloc] init];
    displayParam.isRotateAngleValid = NO;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.locationViewImgName = @"";
    displayParam.locationViewOffsetX = 0;//定位偏移量（经度）
    displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
    _displayParam = displayParam;
    
    [self.mapView updateLocationViewWithParam:_displayParam];
    
    
    [self.view addSubview:self.mapView];
    _mapView.showsUserLocation = YES;

    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    [_locService startUserLocationService];
    
   
    for (int i = 0 ; i < _gitudearray.count; i++) {
        // 添加一个PointAnnotation
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = [_titudearray[i] floatValue];
        coor.longitude = [_gitudearray[i] floatValue];
        annotation.coordinate = coor;
        annotation.title = [NSString stringWithFormat:@"第%d个点",i];
        
        [_animationviewarray addObject:annotation];
        
    }
    [_mapView addAnnotations:_animationviewarray];
    [_mapView showAnnotations:_animationviewarray animated:YES];
   
    
//
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
//    [mapView bringSubviewToFront:view];
    
    
    
    view.paopaoView.hidden = NO;

    
    //    [mapView setNeedsDisplay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //3秒后气泡消失
        view.paopaoView.hidden = YES;
        [view setSelected:NO];
    });
    
    //开始线路规划
    BOOL flag = [_searcher walkingSearch:_transitRouteSearchOption];

}


- (void)initializeDataSouce
{
#pragma mark -- 通过经纬度得到城市名称
    
    if (!_geocodesearch) {
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    }
//    _item = [[BMKPointAnnotation alloc]init];
    _geocodesearch.delegate = self;
    [_mapView setZoomLevel:14];
    
    isGeoSearch = false;
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    if (_coorLatitude != nil && _coorLongitude != nil) {
        pt = (CLLocationCoordinate2D){[_coorLatitude floatValue], [_coorLongitude floatValue]};
    }
    if (!_reverseGeocodeSearchOption) {
        _reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    }
    _reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:_reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

#pragma  mark -- BMKGeoCodeSearchDelegate

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    if (!_coorLongitude) {
        UIAlertView *aleater = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"定位失败，请查看是否打开定位" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        [aleater show];
    }else{
        if (error == BMK_SEARCH_NO_ERROR) {
             NSLog(@"%@",result.address);
            
          
        }
       
       
    }
}

-(void)createMap{
    
    [self  initializeUserInterfac];
    [self  initializeDataSouce];
    
//    [self.mapView updateLocationViewWithParam:_displayParam];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _mapView.delegate = self;
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _mapView.delegate = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
