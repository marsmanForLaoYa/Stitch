//
//  NetworkAPI.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/14.
//

#ifndef NetworkAPI_h
#define NetworkAPI_h

#pragma mark - 服务器接口地址
#define BASEURL_DOMAIN @"http://api.rocketbrowser.xyz/jigsaw/"

//HOME
#define API_HOME_APPLICATION_LIST @"v1/application/list"

//数据上报（内购凭证）
#define API_APPSTORE_RECEIPT @"v2/receipt/store"

//登录
#define API_AUTH_LOGIN @"v2/auth/login"
//用户信息
#define API_USER_INFO @"v2/user/info"
//绑定用户
#define API_USER_BIND @"v2/user/binding"
//添加订阅
#define API_RECEIPT_STORE @"v2/receipt/store"

#endif /* NetworkAPI_h */
