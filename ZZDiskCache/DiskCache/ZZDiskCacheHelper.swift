//
//  ZZDiskCacheHelper.swift
//  ZZDiskCache
//
//  Created by duzhe on 16/3/3.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

typealias $ = ZZDiskCacheHelper

public struct ZZDiskCacheHelper {
    
    /**
      本地缓存对象
     */
    static func saveObj(key:String,value:AnyObject?,completeHandler:(()->())? = nil){
    
        ZZDiskCache.sharedCacheObj.stroe(key, value: value, image: nil, data: nil, completeHandler: completeHandler)
        
    }
    
    /**
      本地缓存图片
     */
    static func saveImg(key:String,image:UIImage?,completeHandler:(()->())? = nil){
        
        ZZDiskCache.sharedCacheImage.stroe(key, value: nil, image: image, data: nil, completeHandler: completeHandler)
        
    }
    
    /**
     本地缓存音频 或者其他 NSData类型
     */
    static func saveVoc(key:String,data:NSData?,completeHandler:(()->())? = nil){
    
        ZZDiskCache.sharedCacheVoice.stroe(key, value: nil, image: nil, data: data, completeHandler: completeHandler)
        
    }
    
    /**
      获得本地缓存的对象
     */
    static func getObj(key:String,compelete:((obj:AnyObject?)->())){
        
        ZZDiskCache.sharedCacheObj.retrieve(key, objectGetHandler: compelete, imageGetHandler: nil, voiceGetHandler: nil)
        
    }
    
    /**
     获得本地缓存的图像
     */
    static func getImg(key:String,compelete:((image:UIImage?)->())){
        
        ZZDiskCache.sharedCacheImage.retrieve(key, objectGetHandler: nil, imageGetHandler: compelete, voiceGetHandler: nil)
        
    }
    
    /**
     获得本地缓存的音频数据文件
     */
    static func getVoc(key:String,compelete:((data:NSData?)->())){
        
        ZZDiskCache.sharedCacheVoice.retrieve(key, objectGetHandler: nil, imageGetHandler: nil, voiceGetHandler: compelete)
        
    }

}