//
//  Basket.swift
//  R3PI-TechEval
//
//  Created by Roberto O. Buratti on 11/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import UIKit

class Basket: NSObject {
	//FIXME: this class has evolved to be a "manager", it needs refactoring
	
	static let sharedInstance = Basket()
	
	static let kNotificationProductsAvailable:String = "Basket.kNotificationProductsAvailable"
	static let kNotificationCurrenciesAvailable:String = "Basket.kNotificationCurrenciesAvailable"
	
	let defaultCurrency = "USD"
	var currentCurrency:String = "USD"
	var exchangeRate:Double = 1.0
	
	var rows:[Product:Int] = [:] // code->qty
	var products:[Product] = []
	var currencies:[String:String] = [:]
	
	override init() {
		super.init()
		let serviceManager = ServiceManager.sharedInstance
		serviceManager.products { (products, error) in
			if (error == nil) {
				self.products = products
				print(Basket.kNotificationProductsAvailable)
				NotificationCenter.default.post(name: Notification.Name(rawValue: Basket.kNotificationProductsAvailable),
				                                object: self)
			}
			// TODO: else? it should post an error notification and the observers should popup an alert...
		}
		serviceManager.currencies { (currencies, error) in
			if (error == nil) {
				self.currencies = currencies
				print(Basket.kNotificationCurrenciesAvailable)
				NotificationCenter.default.post(name: Notification.Name(rawValue: Basket.kNotificationCurrenciesAvailable),
				                                object: self)
			}
			// TODO: else? it should post an error notification and the observers should popup an alert...
		}
	}
	
	func add(product:Product, quantity:Int) {
		self.rows[product] = quantity
	}
	
	func remove(product:Product) {
		self.rows.removeValue(forKey: product)
	}
	
	func contains(product:Product) -> Bool {
		return self.rows.keys.contains(product)
	}
	
	func quantity(forProduct product:Product) -> Int {
		return self.rows[product] ?? 0
	}
	
	func product(atIndex index:Int) -> Product? {
		let keys:[Product] = Array(self.rows.keys)
		return keys[index]
	}
	
	func rowAmount(forProduct product:Product) -> Double {
		let qty = self.quantity(forProduct: product)
		let price = product.price * self.exchangeRate
		let amount = Double(qty) * price
		return amount
	}
	
	func totalAmount() -> Double
	{
		var totalAmount:Double = 0.0
		for row in self.rows {
			let product = row.key
			totalAmount += self.rowAmount(forProduct: product)
		}
		return totalAmount
	}
	
	func changeCurrency(newCurrency:String, callback:@escaping (_ error:Error?) -> Void) {
		let serviceManager = ServiceManager.sharedInstance
		serviceManager.quotes(source: self.defaultCurrency, currency: newCurrency) { (quotes:[String : Double], error:Error?) in
			guard (error == nil) else {
				callback(error)
				return
			}
			if let quote = quotes["\(self.defaultCurrency)\(newCurrency)"] {
				self.currentCurrency = newCurrency
				self.exchangeRate = quote
			}
			callback(nil)
		}
	}
	
}
