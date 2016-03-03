//
//  Student.swift
//  ZZDiskCache
//
//  Created by duzhe on 16/3/3.
//  Copyright © 2016年 dz. All rights reserved.
//

import Foundation

class Student: NSObject,NSCoding {
    
    var id:NSNumber?
    var name:String?
    
    override init() {
        
    }
    
    //MARK: -序列化
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.id, forKey: "id")
    }
    
    
    //MARK: -反序列化
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey("id") as? NSNumber
        self.name = aDecoder.decodeObjectForKey("name") as? String
    }
}
