//
//  AppGroupData.m
//  YXStitch
//
//  Created by xwan-iossdk on 2022/8/8.
//

#import "AppGroupData.h"


@interface AppGroupData ()

@end

@implementation AppGroupData

+ (NSDictionary *_Nonnull)packetWithSampleBuffer:(CMSampleBufferRef _Nullable )sampleBuffer{
    // output data
    int16_t format = -1;
    int32_t strideY = -1;
    int32_t strideU = -1;
    int32_t strideV = -1;
    uint8_t * dataPtr = NULL;
    int32_t width = -1;
    int32_t height = -1;
    uint32_t dataLength = 0;
    int32_t rotation = 0;
    // get CVPixelBuffer
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    const OSType pixel_format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    // CVPixelBuffer to yuv(nv12) data
    if(pixel_format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ||
       pixel_format == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t w = CVPixelBufferGetWidth(pixelBuffer);
        size_t h = CVPixelBufferGetHeight(pixelBuffer);
        size_t src_y_stride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t src_uv_stride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
       
        size_t bufferSize = w * h * 3 / 2;
        // buffer
        uint8_t * buffer = (uint8_t*)malloc(bufferSize);
        unsigned char* dst = buffer;
        unsigned char* src_y = (unsigned char*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        unsigned char* src_uv = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        // copy y
        size_t height_y = h;
        for (unsigned int rIdx = 0; rIdx < height_y; ++rIdx, dst += w, src_y += src_y_stride) {
            memcpy(dst, src_y, w);
        }
        // copy uv
        size_t height_uv = h >> 1;
        for (unsigned int rIdx = 0; rIdx < height_uv; ++rIdx, dst += w, src_uv += src_uv_stride) {
            memcpy(dst, src_uv, w);
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        // frame
        format = 3; // AliRtcVideoFormat_NV12;
     
        strideY = (int32_t)w;
        strideU = (int32_t)w;
        strideV = (int32_t)w / 2;
        dataPtr = buffer;
        width = (int32_t)w;
        height = (int32_t)h;
        dataLength = bufferSize;
        
    } else if(pixel_format == kCVPixelFormatType_32BGRA){ // CVPixelBuffer to rgb data
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t w = CVPixelBufferGetWidth(pixelBuffer);
        size_t h = CVPixelBufferGetHeight(pixelBuffer);
        uint8_t *buffer = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t stride = CVPixelBufferGetBytesPerRow(pixelBuffer);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        // frame
        format = 0; // AliRtcVideoFormat_BGRA;
        strideY = (int32_t)stride;
        strideU = 0;
        strideV = 0;
        dataPtr = buffer;
        width = (int32_t)w;
        height = (int32_t)h;
        dataLength = stride * h;
    } else {
        NSLog(@"(Error)unsupported pixelBuffer format");
        return NULL;
    }
    if(format == -1 ||  dataPtr == NULL || width == -1 || height == -1 || dataLength == 0){
        NSLog(@"(Error)wrong output params");
        return NULL;
    }
    int32_t orientation = ((NSNumber *)CMGetAttachment(sampleBuffer,
                                                            (__bridge CFStringRef)RPVideoSampleOrientationKey,
                                                          NULL)).intValue;
    switch (orientation) {
        case kCGImagePropertyOrientationUp:
            rotation = 0;
            break;
        case kCGImagePropertyOrientationLeft:
            rotation = 90;
            break;
        case kCGImagePropertyOrientationDown:
            rotation = 180;
            break;
        case kCGImagePropertyOrientationRight:
            rotation = 270;
            break;
        default:
            break;
    }
    //int64_t timeStampNs = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * 1000000000;
    NSData *data = [NSData dataWithBytesNoCopy:dataPtr length:dataLength];
    // 组合成frame(一般屏幕采集都为nv12)
    NSDictionary *nv12Frame = @{
        kPropFormat: @(format),
        kPropWidth: @(width),
        kPropHeight: @(height),
        kPropStrideY: @(strideY),
        kPropStrideU: @(strideU),
        kPropStrideV: @(strideV),
        kPropDataLength: @(dataLength),
        kPropData: data,
        kPropRotation: @(rotation),
    };
    return nv12Frame;
}

@end
