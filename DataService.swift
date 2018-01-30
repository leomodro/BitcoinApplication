//
//  DataService.swift
//  BitcoinApplication
//
//  Created by Leonardo Modro on 30/01/2018.
//  Copyright © 2018 Leonardo Modro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class DataService {
    private static var alloc: DataService?
    static var instance: DataService {
        get {
            if alloc == nil {
                alloc = DataService()
            }
            return alloc!
        }
    }
    
    func request(url: String, params: [String: AnyObject]?, method: HTTPMethod, encoding: ParameterEncoding, completion: ((_ success: Bool, _ data: NSData?, _ error: NSError?) -> Void)?) {
        Alamofire.request(url, method: method, parameters: params, encoding: encoding)
            .validate()
            .responseData { (data) in
                completion?(true, data.data as NSData?, nil)
        }
    }
}
