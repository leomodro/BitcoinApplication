//
//  Constants.swift
//  BitcoinApplication
//
//  Created by Leonardo Modro on 31/01/2018.
//  Copyright © 2018 Leonardo Modro. All rights reserved.
//

import UIKit

struct Request {
    static let historyPrice = "https://api.blockchain.info/charts/market-price?timespan=5weeks&format=json"
    static let latestPrice = "https://api.blockchain.info/stats"
}

struct Color {
    static let title = UIColor.hexToUIColor(hex: "DCDDDD")
    static let background = UIColor.hexToUIColor(hex: "2D3134")
    static let lineChart = UIColor.hexToUIColor(hex: "777777")
    static let gradientStart = UIColor.hexToUIColor(hex: "555555")
    static let gradientEnd = UIColor.hexToUIColor(hex: "444444")
}
