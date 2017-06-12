//
//  CurrencyPickerViewController.swift
//  R3PI-TechEval
//
//  Created by Roberto O. Buratti on 12/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import UIKit

protocol CurrencyPickerDelegate: class {
	func currencyPicker(_ currencyPicker: CurrencyPickerViewController, didSelectCurrency currency: String)
}

class CurrencyPickerViewController: UITableViewController {
	
	weak var delegate:CurrencyPickerDelegate?
	
	var currencies:[[String:String]] = []
	var indexPathForCurrentCurrency:IndexPath?
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.title = "Currencies"
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
		                                                         target: self,
		                                                         action: #selector(onButtonCancelDidTap))

		NotificationCenter.default.addObserver(self,
		                                       selector:#selector(onNotificationCurrenciesAvailable),
		                                       name: Notification.Name(rawValue: Basket.kNotificationCurrenciesAvailable),
		                                       object:nil)

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.reloadData()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CurrencyPickerViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.currencies.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CurrencyPickerCell", for: indexPath)
		let currency = self.currencies[indexPath.row]
		
		cell.textLabel?.text = currency.values.first
		cell.detailTextLabel?.text = currency.keys.first
		
		if (indexPath == self.indexPathForCurrentCurrency) {
			cell.accessoryType = UITableViewCellAccessoryType.checkmark
		} else {
			cell.accessoryType = UITableViewCellAccessoryType.none
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let delegate = self.delegate {
			let currency = self.currencies[indexPath.row]
			delegate.currencyPicker(self, didSelectCurrency: currency.values.first!)
		}
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Events & Notifications

extension CurrencyPickerViewController {
	
	func onNotificationCurrenciesAvailable() {
		self.reloadData()
	}
	
	func onButtonCancelDidTap() {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Private methods

extension CurrencyPickerViewController {
	
	func reloadData() {
		var currentCurrencyName:String?
		let basket = Basket.sharedInstance
		for currency in basket.currencies {
			self.currencies.append([currency.value:currency.key])	// use currency name as key
			if (currency.key == basket.currentCurrency) {
				currentCurrencyName = currency.value
			}
		}
		self.currencies.sort { (c1:[String:String], c2:[String:String]) -> Bool in
			return c1.keys.first! < c2.keys.first!
		}
		self.tableView.reloadData()
		if let name = currentCurrencyName {
			let index = self.currencies.index(where: { (c:[String : String]) -> Bool in
				return c.keys.first! == name
			})
			if let row = index {
				self.indexPathForCurrentCurrency = IndexPath(row: row, section: 0)
				//self.tableView.selectRow(at: self.indexPathForCurrentCurrency, animated: true, scrollPosition: UITableViewScrollPosition.none)
				self.tableView.scrollToRow(at: self.indexPathForCurrentCurrency!, at: UITableViewScrollPosition.none, animated: true)
			}
		}
	}
}

