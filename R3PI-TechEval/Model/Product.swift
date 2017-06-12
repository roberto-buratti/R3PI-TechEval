//
//  Product.swift
//  R3PI-TechEval
//
//  Created by Roberto O. Buratti on 11/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import UIKit

class Product: NSObject {
	var code: String
	var title: String
	var imageName: String
	var unit: String
	var price: Double
	
	init(withDictionary dictionary:[String:Any]) {
		self.code = dictionary["code"] as? String ?? "#unknown-product"
		self.title = dictionary["title"] as? String ?? "Unknown product"
		self.imageName = dictionary["image"] as? String ?? ""
		self.unit = dictionary["unit"] as? String ?? "?"
		self.price = dictionary["price"] as? Double ?? 0.0
		super.init()
	}
}
