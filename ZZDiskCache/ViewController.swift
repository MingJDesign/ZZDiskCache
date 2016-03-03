//
//  ViewController.swift
//  ZZDiskCache
//
//  Created by duzhe on 16/3/2.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

       let homePath = NSHomeDirectory()
        
       print(homePath)
        
       let stu = Student()
       stu.name = "小王"
       stu.id = 1
       $.saveObj("xxxx", value: stu)
        
       $.getObj("xxxx") { (obj) -> () in
         if let obj = obj as? Student{
            print("\(obj.id) , \(obj.name)")
         }
       }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

