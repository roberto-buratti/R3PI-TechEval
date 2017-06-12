//
//  ServiceManager.swift
//  R3PI-TechEval
//
//  Created by Roberto O. Buratti on 11/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import UIKit

class ServiceManager: NSObject {
	
	static let sharedInstance = ServiceManager()
	
	internal let accessKey = "6292dcbc34456a4a53ad787c9fa048dc"
	internal let serverURL = "http://apilayer.net/api"
	
	internal var urlSession:URLSession
	
	internal var networkActivityCounter = 0
	internal var isNetworkActivityIndicatorVisible:Bool {
		get {
			return self.networkActivityCounter > 0
		}
		set {
			self.networkActivityCounter += (newValue ? 1 : -1);
			self.networkActivityCounter = max(0, self.networkActivityCounter);	// ...vurjìa mai
			UIApplication.shared.isNetworkActivityIndicatorVisible = (self.networkActivityCounter != 0);
		}
	}
	
	override init() {
		self.urlSession = URLSession(configuration:URLSessionConfiguration.default)
		super.init()
	}
	
	func products(callback:(_ products: [Product], _ error:Error?) -> Void) {
		var products:[Product] = []
		var failure:Error?
		do {
			let bundle = Bundle.main
			let path = "\(bundle.bundlePath)/products.json"
			let url = URL(fileURLWithPath: path)
			let data = try Data(contentsOf: url)
			let json = try JSONSerialization.jsonObject(with: data)
			if let array = json as? [[String:Any]] {
				for dicto in array {
					let product = Product(withDictionary: dicto)
					products.append(product)
				}				
			}
		} catch   {
			print(error)
			failure = error
		}
		callback(products, failure)
	}
	
	func currencies(callback:@escaping (_ currencies: [String:String], _ error:Error?) -> Void) {
		_ = self.invoke(endpoint:"list", params:nil) { (response, error) in
			var currencies:[String:String] = [:]
			if (response?["currencies"] is [String:String]) {
				currencies = response?["currencies"] as! [String : String]
			}
			callback(currencies, error)
		}
	}

	func quotes(source:String, currency:String, callback:@escaping (_ quotes: [String:Double], _ error:Error?) -> Void) {
		var params:[String:Any] = [:]
		params["source"] = source
		params["currencies"] = currency
		_ = self.invoke(endpoint:"live", params:params) { (response, error) in
			var quotes:[String:Double] = [:]
			if (response?["quotes"] is [String:Double]) {
				quotes = response?["quotes"] as! [String:Double]
			}
			callback(quotes, error)
		}
	}
}

fileprivate extension ServiceManager {
	
	func invoke(endpoint:String, params:[String:Any]?, callback:@escaping (_ response: [String:Any]?, _ error:Error?) -> Void) -> URLSessionDataTask {
		
		var urlString = "\(self.serverURL)/\(endpoint)"
		urlString.append("?access_key=\(self.accessKey)")
		//urlString.append("&format=1")
		if let p = params {
			for item in p {
				urlString.append("&\(item.key)=\(item.value)")
			}
		}
		
		let url = URL(string:urlString)
		var request = URLRequest(url: url!)
		request.httpMethod = "GET"
		//request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		
		self.isNetworkActivityIndicatorVisible = true;
		
		let task = self.urlSession.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
			print("\(self).invoke: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
			self.isNetworkActivityIndicatorVisible = false
			var jsonResponse:[String:Any] = [:]
			if let responseData = data {
				do {
					let jsonObject = try JSONSerialization.jsonObject(with: responseData)
					if (jsonObject is [String:Any]) {
						jsonResponse = jsonObject as! [String : Any]
					}
				} catch  {
					print(error)
				}
			}
			callback(jsonResponse, error)
		}
		
		task.resume()
		
		return task;
	}
	
}
