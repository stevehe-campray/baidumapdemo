//
//  AppDelegate.h
//  mapTest
//
//  Created by hejingjin on 16/7/7.
//  Copyright © 2016年 Chinahr. All rights reserved.
//

#import <UIKit/UIKit.h>
//------------------------------百度---------------------------------
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
     BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;


@end

