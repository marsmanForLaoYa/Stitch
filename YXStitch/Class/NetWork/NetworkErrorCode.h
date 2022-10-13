//
//  NetworkErrorCode.h
//  XWNWS
//
//  Created by mac_m11 on 2022/9/15.
//

#ifndef NetworkErrorCode_h
#define NetworkErrorCode_h

typedef NS_ENUM(NSInteger, NetworkErrorCode)
{
    CodeSuccess = 0,
    CodeParamError = -1,          //参数错误
    CodeRegisterFailed = -2,      //注册失败
    CodeBindInviteCodeNoExist = -2,    //邀请码不存在
    CodeBindHadBindUser = -3,          //已经绑定用户
    CodeBindError = -4,                //绑定失败
    CodeRequestMethodError = -503 ,    //请求方法错误
    CodeErrorEmpty = -666,      //返回的空数据
    CodeErrorNetworkConnectionLost = -1005,  // "网络连接异常"
    CodeErrorDataNotAllowed = -1020, //数据不被允许
    CodeErrorNotConnectedToInternet = -1009,  // "无网络连接"
    CodeErrorBadServerResponse = -1011,  // "服务器响应异常"
    CodeErrorCannotConnectToHost = -1004,  // "连接不上服务器"
};

#endif /* NetworkErrorCode_h */
