//
//  ViewController.swift
//  BitcoinApplication
//
//  Created by Leonardo Modro on 30/01/2018.
//  Copyright © 2018 Leonardo Modro. All rights reserved.
//

import UIKit
import SnapKit
import ScrollableGraphView
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {
    
    var graphView: ScrollableGraphView!
    var latestPrice: UILabel = {
        var lbl = UILabel()
        lbl.text = "ÚLTIMA COTAÇÃO"
        lbl.textColor = UIColor.hexToUIColor(hex: "DCDDDD")
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.sizeToFit()
        return lbl
    }()
    
    var price: UILabel = {
        var lbl = UILabel()
        lbl.text = "$ 10.000,00"
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.sizeToFit()
        return lbl
    }()
    
    var history: UILabel = {
        var lbl = UILabel()
        lbl.text = "HISTÓRICO DA COTAÇÃO"
        lbl.textColor = UIColor.hexToUIColor(hex: "DCDDDD")
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.sizeToFit()
        return lbl
    }()

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexToUIColor(hex: "2D3134")
        fetchMarketPrices()
        setupNavigationBar()
        setupInterfaceItems()
    }
    
    //MARK: - Setting up UI
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.hexToUIColor(hex: "2D3134")
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = "Dashboard"
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func setupInterfaceItems() {
        [latestPrice, price, history].forEach({view.addSubview($0)})
        
        latestPrice.snp.makeConstraints { (make) in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        
        price.snp.makeConstraints { (make) in
            make.leading.equalTo(latestPrice.snp.leading)
            make.top.equalTo(latestPrice.snp.bottom).offset(10)
        }
        
        history.snp.makeConstraints { (make) in
            make.leading.equalTo(latestPrice.snp.leading)
            make.top.equalTo(price.snp.bottom).offset(80)
        }
    }
    
    private func setupGraph(_ frame: CGRect) {
        graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let linePlot = LinePlot(identifier: "darkLine")
        
        linePlot.lineWidth = 1
        linePlot.lineColor = UIColor.hexToUIColor(hex: "777777")
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.gradient
        linePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        linePlot.fillGradientStartColor = UIColor.hexToUIColor(hex: "555555")
        linePlot.fillGradientEndColor = UIColor.hexToUIColor(hex: "444444")
        
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let dotPlot = DotPlot(identifier: "darkLineDot")
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = UIColor.white
        
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        
        referenceLines.positionType = .absolute
        referenceLines.absolutePositions = [10.000, 12.000, 14.000, 16.000, 18.000, 20.000]
        referenceLines.includeMinMax = false
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.backgroundFillColor = UIColor.hexToUIColor(hex: "333333")
        graphView.dataPointSpacing = 80
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.shouldRangeAlwaysStartAtZero = true
        
        graphView.rangeMax = 50
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: linePlot)
        graphView.addPlot(plot: dotPlot)
    }
    
    //MARK: - Request to API
    private func fetchMarketPrices() {
        let url = "https://api.blockchain.info/charts/market-price?timespan=1week&format=json"
        DataService.instance.request(url: url, params: nil, method: HTTPMethod.get, encoding: URLEncoding.httpBody) { (success, data, error) in
            do {
                let json = try JSON(data: data! as Data)
                for value in json["values"].arrayValue {
                    let timestamp = value["x"].doubleValue
                    let price = value["y"].doubleValue
                    print(price)
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d"
                    let strDate = dateFormatter.string(from: date)
                    print(strDate)
                }
            } catch {
                debugPrint("Error loading json")
            }
        }
    }
}

extension ViewController: ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return 0.0
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return ""
    }
    
    func numberOfPoints() -> Int {
        return 0
    }
}

