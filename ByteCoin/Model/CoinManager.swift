//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRate(_ coinManager: CoinManager, rate: Double)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "9BAB8E35-FE39-4CE7-ADDD-DBD5F366FE0B"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var currency: String = ""
    var delegate: CoinManagerDelegate?
    
    mutating func getCoinPrice(for currency: String) {
        self.currency = currency
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let cleanUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: cleanUrlString) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, response, error) in
                    if(error != nil) {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let rate = self.parseJSON(safeData) {
                            self.delegate?.didUpdateRate(self, rate: rate)
                        }
                    }
                }
                task.resume()
            }
        } else {
            print("Badly formatted URL!")
        }
    }
    
    func parseJSON(_ coinData: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            return rate
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

