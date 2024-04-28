#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SslCertificate, NSObject)

RCT_EXTERN_METHOD(getCertificate:(NSString *)url
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
