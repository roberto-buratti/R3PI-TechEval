//
//  R3PI_TechEvalTests.swift
//  R3PI-TechEvalTests
//
//  Created by Roberto O. Buratti on 11/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import XCTest
@testable import R3PI_TechEval

class R3PI_TechEvalTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasketInit() {
		let promise1 = self.expectation(forNotification: Basket.kNotificationProductsAvailable, object: nil) { (notification:Notification) -> Bool in
			print(notification)
			return true
		}
		
		let promise2 = self.expectation(forNotification: Basket.kNotificationCurrenciesAvailable, object: nil) { (notification:Notification) -> Bool in
			print(notification)
			return true
		}
		
		let basket = Basket.sharedInstance // force singleton initialization
		
// FIXME: for testing purpouses would be better to have an explicit call to load products & currencies. But it would be worst for coding purpouses... so, quick & dirty testing (we KNOW that if basket.products.count > 0, then the notification has surely been posted)
		
		if (basket.products.count > 0) {
			promise1.fulfill()	// singleton was already initialized at the moment this test did start
		}
		
		if (basket.currencies.count > 0) {
			promise2.fulfill()	// singleton was already initialized at the moment this test did start
		}
		
		self.wait(for: [promise1, promise2], timeout: 5)
    }
	
	func testBasketAddRemoveProduct() {
		
		let promise = self.expectation(forNotification: Basket.kNotificationProductsAvailable, object: nil) { (notification:Notification) -> Bool in
			let basket = Basket.sharedInstance
			let product = basket.products.first
			guard product != nil else {
				XCTAssert(false, "*** failed to get first product")
				return false
			}
			basket.add(product: product!, quantity: 1)
			XCTAssertTrue(basket.rows.count == 1, "*** failed to add product")
			basket.remove(product: product!)
			XCTAssertTrue(basket.rows.count == 0, "*** failed to remove product")
			return true
		}
		
		let basket = Basket.sharedInstance	// force singleton initialization
		
		if (basket.products.count > 0) {
			let basket = Basket.sharedInstance
			let product = basket.products.first
			if product == nil {
				XCTAssert(false, "*** failed to get first product")
			} else {
				basket.add(product: product!, quantity: 1)
				XCTAssertTrue(basket.rows.count == 1, "*** failed to add product")
				basket.remove(product: product!)
				XCTAssertTrue(basket.rows.count == 0, "*** failed to remove product")
				promise.fulfill()	// singleton was already initialized at the moment this test did start
			}
		}

		self.waitForExpectations(timeout: 5, handler: nil)
	}
	
	func testServiceManagerCurrencies() {
		
		let serviceManager = ServiceManager.sharedInstance
		
		let promise = self.expectation(description: "Trying to get currencies")
		
		serviceManager.currencies { (currencies:[String : String], error:Error?) in
			XCTAssertNil(error, "*** failed to get currencies: \(String(describing: error))")
			XCTAssert(currencies.count > 0, "*** failed to get currencies: count == 0")
			promise.fulfill()
		}
		
		self.waitForExpectations(timeout: 5, handler: nil)
	}
    
	func testServiceManagerQuotes() {
		
		let serviceManager = ServiceManager.sharedInstance
		
		let promise = self.expectation(description: "Trying to get quotes")
		
		serviceManager.quotes(source: "USD", currency: "EUR") { (quotes:[String : Double], error:Error?) in
			XCTAssertNil(error, "*** failed to get quotes: \(String(describing: error))")
			XCTAssert(quotes.count > 0, "*** failed to get quotes: count == 0")
			promise.fulfill()
		}
		
		self.waitForExpectations(timeout: 5, handler: nil)
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
