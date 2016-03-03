//
//  ZZDiskCache.swift
//  ZZDiskCache
//
//  Created by duzhe on 16/3/2.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

private let page = ZZDiskCache(type:.Object)
private let image = ZZDiskCache(type:.Image)
private let voice = ZZDiskCache(type:.Voice)

//会在cache下创建目录管理
enum CacheFor:String{
    case Object = "zzObject"     //页面对象缓存 (缓存的对象)
    case Image = "zzImage"  //图片缓存 (缓存NSData)
    case Voice = "zzVoice"  //语音缓存 (缓存NSData)
}

public class ZZDiskCache {

    private let defaultCacheName = "zz_default"
    private let cachePrex = "com.zz.zzdisk.cache."
    private let ioQueueName = "com.zz.zzdisk.cache.ioQueue."
    
    private var fileManager: NSFileManager!
    private let ioQueue: dispatch_queue_t
    var diskCachePath:String
    // 针对Page
    public class var sharedCacheObj: ZZDiskCache {
        return page
    }
    
    // 针对Image
    public class var sharedCacheImage: ZZDiskCache {
        return image
    }
    
    // 针对Voice
    public class var sharedCacheVoice: ZZDiskCache {
        return voice
    }
    
    private var storeType:CacheFor
    
    init(type:CacheFor) {
        self.storeType = type
        let cacheName = cachePrex+type.rawValue
        ioQueue = dispatch_queue_create(ioQueueName+type.rawValue, DISPATCH_QUEUE_SERIAL)
        //获取缓存目录
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        //缓存目录下创建一个子目录
        diskCachePath = (paths.first! as NSString).stringByAppendingPathComponent(cacheName)
        
        dispatch_sync(ioQueue) { () -> Void in
            self.fileManager = NSFileManager()
            //创建子目录对应的文件夹
            do {
                try self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
    }
    
    
    /**
     存储
     
     - parameter key:             键
     - parameter value:           值
     - parameter image:           图像
     - parameter data:            data
     - parameter completeHandler: 完成回调
     */
    public func stroe(key:String,value:AnyObject? = nil,image:UIImage?,data:NSData?,completeHandler:(()->())? = nil){
        let path = self.cachePathForKey(key)
        switch storeType{
        case .Object:
            print("save Object ")
            self.stroeObject(key, value: value,path:path,completeHandler:completeHandler)
        case .Image:
            print("save Image ")
            if let image = image{
                self.storeImage(image, forKey: key, path: path, completeHandler: completeHandler)
            }
        case .Voice:
            print("save Voice ")
            self.storeVoice(data, forKey: key, path: path, completeHandler: completeHandler)
        }
    }
    
    /**
     对象存储 归档操作后写入文件
     
     - parameter key:   键
     - parameter value: 值
     - parameter path: 路径
     - parameter completeHandler: 完成后回调
     */
    private func stroeObject(key:String,value:AnyObject?,path:String,completeHandler:(()->())? = nil){
        dispatch_async(ioQueue){
            let data = NSMutableData()  //声明一个可变的Data对象
            //创建归档对象
            let keyArchiver = NSKeyedArchiver(forWritingWithMutableData: data)
            //开始归档
            keyArchiver.encodeObject(value, forKey: key.zz_MD5())  //对key进行MD5加密
            //完成归档
            keyArchiver.finishEncoding() //归档完毕
            
            do {
                //写入文件
                try data.writeToFile(path, options: NSDataWritingOptions.DataWritingAtomic)  //存储
                //完成回调
                completeHandler?()
            }catch let err{
                print("err:\(err)")
            }
        }
    }
    
    /**
     图像存储
     
     - parameter image:           image
     - parameter key:             键
     - parameter path:            路径
     - parameter completeHandler: 完成回调
     */
    private func storeImage(image:UIImage,forKey key:String,path:String,completeHandler:(()->())? = nil){
        dispatch_async(ioQueue) {
            let data = UIImagePNGRepresentation(image.zz_normalizedImage())
            if let data = data {
                self.fileManager.createFileAtPath(path, contents: data, attributes: nil)
            }
        }
    }
    
    /**
     存储声音
     
     - parameter data:            data
     - parameter key:             键
     - parameter path:            路径
     - parameter completeHandler: 完成回调
     */
    private func storeVoice(data:NSData?,forKey key:String,path:String,completeHandler:(()->())? = nil){
        dispatch_async(ioQueue) {
            if let data = data {
                self.fileManager.createFileAtPath(path, contents: data, attributes: nil)
            }
        }
    }
    
    /**
     获取数据的方法
     
     - parameter key:              键
     - parameter objectGetHandler: 对象完成回调
     - parameter imageGetHandler:  图像完成回调
     - parameter voiceGetHandler:  音频完成回调
     */
    public func retrieve(key:String,objectGetHandler:((obj:AnyObject?)->())? = nil,imageGetHandler:((image:UIImage?)->())? = nil,voiceGetHandler:((data:NSData?)->())?){
        let path = self.cachePathForKey(key)
        switch storeType{
        case .Object:
            self.retrieveObject(key.zz_MD5(), path: path, objectGetHandler: objectGetHandler)
        case .Image:
            self.retrieveImage(path,imageGetHandler:imageGetHandler)
        case .Voice:
            self.retrieveVoice(path, voiceGetHandler: voiceGetHandler)
        }
    }
    
    
    /**
     获取文件归档对象
     
     - parameter key:              键
     - parameter path:             路径
     - parameter objectGetHandler: 获得后回调闭包
     */
    private func retrieveObject(key:String,path:String,objectGetHandler:((obj:AnyObject?)->())?){
        //反归档 获取
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if self.fileManager.fileExistsAtPath(path){
                let mdata = NSMutableData(contentsOfFile:path)  //声明可变Data
                let unArchiver = NSKeyedUnarchiver(forReadingWithData: mdata!) //反归档对象
                let obj = unArchiver.decodeObjectForKey(key)    //反归档
                objectGetHandler?(obj:obj)  //完成回调
            }
                objectGetHandler?(obj:nil)
        }
    }
    
    /**
     获取图片
     
     - parameter path:            路径
     - parameter imageGetHandler: 获得后回调闭包
     */
    private func retrieveImage(path:String,imageGetHandler:((image:UIImage?)->())?){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let data = NSData(contentsOfFile: path){
                if let image = UIImage(data: data){
                    imageGetHandler?(image: image)
                }
            }
            imageGetHandler?(image: nil)
        }
    }
    
    /**
     获取音频数据
     
     - parameter path:            路径
     - parameter voiceGetHandler: 获得后回调闭包
     */
    private func retrieveVoice(path:String,voiceGetHandler:((data:NSData?)->())?){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let data = NSData(contentsOfFile: path){
                voiceGetHandler?(data: data)
            }
            voiceGetHandler?(data: nil)
        }
    }
}

extension ZZDiskCache{
    func cachePathForKey(key: String) -> String {
        let fileName = cacheFileNameForKey(key)     //对name进行MD5加密
        return (diskCachePath as NSString).stringByAppendingPathComponent(fileName)
    }
    
    func cacheFileNameForKey(key: String) -> String {
        return key.zz_MD5()
    }
}


extension UIImage {
    
    func zz_normalizedImage() -> UIImage {
        if imageOrientation == .Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage;
    }
}


