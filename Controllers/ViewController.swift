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
    var marketPrices: [MarketPrice] = []
    var latestPrice: UILabel = {
        var lbl = UILabel()
        lbl.text = "ÚLTIMA COTAÇÃO"
        lbl.textColor = Color.title
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.sizeToFit()
        return lbl
    }()
    
    var price: UILabel = {
        var lbl = UILabel()
        lbl.text = "$ 0"
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.sizeToFit()
        return lbl
    }()
    
    var history: UILabel = {
        var lbl = UILabel()
        lbl.text = "HISTÓRICO DA COTAÇÃO"
        lbl.textColor = Color.title
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.sizeToFit()
        return lbl
    }()

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.background
        setupNavigationBar()
        setupInterfaceItems()
        DispatchQueue.global().async {
            self.fetchLatestPrice()
        }
        fetchMarketPrices()
    }
    
    //MARK: - Setting up UI
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = Color.background
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
    
    private func setupGraph() {
        graphView = ScrollableGraphView(frame: CGRect(x: 12, y: 300, width: 300, height: 300), dataSource: self)
        
        let linePlot = LinePlot(identifier: "darkLine")
        
        linePlot.lineWidth = 1
        linePlot.lineColor = Color.lineChart
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.gradient
        linePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        linePlot.fillGradientStartColor = Color.gradientStart
        linePlot.fillGradientEndColor = Color.gradientEnd
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let dotPlot = DotPlot(identifier: "darkLineDot")
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = UIColor.white
        
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.positionType = .absolute
        referenceLines.absolutePositions = [10000, 12000, 14000, 16000, 18000]
        referenceLines.referenceLineNumberStyle = .currencyAccounting
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphView.backgroundFillColor = Color.background
        graphView.dataPointSpacing = 80
        graphView.shouldAnimateOnStartup = true
        // Disable Adapt Range to remove animations when scrolling
        graphView.shouldAdaptRange = false
        graphView.shouldAdaptRange = true
        graphView.rangeMin = 10000
        graphView.rangeMax = 18000
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: linePlot)
        graphView.addPlot(plot: dotPlot)
        
        self.view.addSubview(graphView)
        graphView.snp.makeConstraints { (make) in
            make.top.equalTo(history.snp.bottom).offset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
        }
    }
    
    //MARK: - Request to API
    private func fetchMarketPrices() {
        DataService.instance.request(url: Request.historyPrice, params: nil, method: HTTPMethod.get, encoding: URLEncoding.httpBody) { (success, data, error) in
            if error != nil {
                let alert = UIAlertController()
                alert.generate(parent: self, title: "Atenção", message: "Não foi possível recuperar o histórico de cotações. Por favor, tente novamente mais tarde", buttonText: "OK")
            } else {
                do {
                    let json = try JSON(data: data! as Data)
                    for value in json["values"].arrayValue {
                        let timestamp = value["x"].doubleValue
                        let price = value["y"].doubleValue
                        
                        let date = Date(timeIntervalSince1970: timestamp)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM d"
                        let strDate = dateFormatter.string(from: date)
                        self.marketPrices.append(MarketPrice(date: strDate, price: price.rounded()))
                    }
                    self.setupGraph()
                } catch {
                    debugPrint("Error loading json")
                }
            }
        }
    }
    
    private func fetchLatestPrice() {
        DataService.instance.request(url: Request.latestPrice, params: nil, method: HTTPMethod.get, encoding: URLEncoding.httpBody) { (success, data, error) in
            if error != nil {
                let alert = UIAlertController()
                alert.generate(parent: self, title: "Atenção", message: "Não foi possível recuperar a última cotação. Por favor, tente novamente mais tarde", buttonText: "OK")
            } else {
                do {
                    let json = try JSON(data: data! as Data)
                    let price = json["market_price_usd"].doubleValue
                    let formatter = NumberFormatter()
                    formatter.locale = Locale(identifier: "en_US")
                    formatter.numberStyle = .currency
                    if let formattedPrice = formatter.string(from: price.rounded() as NSNumber) {
                        self.price.text = "\(formattedPrice)"
                    }
                } catch {
                    debugPrint("Error loading json")
                }
            }
        }
    }
}

//MARK: -
extension ViewController: ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return marketPrices[pointIndex].price
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return marketPrices[pointIndex].date
    }
    
    func numberOfPoints() -> Int {
        return marketPrices.count
    }
}

