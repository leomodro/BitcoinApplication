//
//  UIAlertController.swift
//  BitcoinApplication
//
//  Created by Leonardo Modro on 31/01/2018.
//  Copyright © 2018 Leonardo Modro. All rights reserved.
//

import UIKit

extension UIAlertController {
    func generate(parent: UIViewController, title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.default, handler: nil))
        parent.present(alert, animated: true, completion: nil)
    }
}
