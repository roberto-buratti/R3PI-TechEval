//
//  BasketViewController.swift
//  R3PI-TechEval
//
//  Created by Roberto O. Buratti on 12/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import UIKit

class BasketViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,CurrencyPickerDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var buttonCurrencies:UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.title = "Basket"
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
		                                                         target: self,
		                                                         action: #selector(onButtonDoneDidTap))
		self.buttonCurrencies.target = self
		self.buttonCurrencies.action = #selector(onButtonCurrenciesDidTap)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if (segue.destination is ProductViewController) {
			let cntrl = segue.destination as! ProductViewController
			cntrl.product = (sender as! Product)
		} else if (segue.destination is UINavigationController) {
			let navCntrl = segue.destination as! UINavigationController
			if (navCntrl.topViewController is CurrencyPickerViewController) {
				let topCntrl = navCntrl.topViewController as! CurrencyPickerViewController
				topCntrl.delegate = self
			}
		}
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension BasketViewController {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			let basket = Basket.sharedInstance
			return basket.rows.keys.count
		case 1:
			return 1;
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Your Products"
		case 1:
			return " "
		default:
			return ""
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let basket = Basket.sharedInstance
		if (indexPath.section == 0) {
			let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "BasketRowCell", for: indexPath)
			if let product = basket.product(atIndex:indexPath.row) {
				cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
				cell.imageView?.image = UIImage(named: product.imageName)
				cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
				cell.imageView?.layer.borderWidth = 1
				cell.textLabel?.text = product.title
				
				let qty = basket.quantity(forProduct: product)
				cell.detailTextLabel?.text = "\(qty) \(product.unit)(s)"
				
				let labelAmount = UILabel()
				labelAmount.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
				
				labelAmount.text = "\(basket.rowAmount(forProduct: product)) \(basket.currentCurrency)"
				labelAmount.sizeToFit()
				cell.accessoryView = labelAmount
			}
			
			return cell
		} else {
			let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "BasketTotalCell", for: indexPath)
			cell.textLabel?.text = "TOTAL"
			
			let totalAmount = basket.totalAmount()
			cell.detailTextLabel?.text = "\(totalAmount) \(basket.currentCurrency)"
			
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.layoutIfNeeded()
		cell.imageView?.layer.masksToBounds = true;
		cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let basket = Basket.sharedInstance
		let product = basket.product(atIndex:indexPath.row)
		self.performSegue(withIdentifier: "ProductSegue", sender: product)
	}
}

// MARK: - CurrencyPickerDelegate

extension BasketViewController {
	func currencyPicker(_ currencyPicker: CurrencyPickerViewController, didSelectCurrency currency: String) {
		let basket = Basket.sharedInstance
		basket.changeCurrency(newCurrency: currency) { (error:Error?) in
			DispatchQueue.main.async {
				if error != nil {
					let alert:UIAlertController = UIAlertController(title: "Wooops", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
				self.tableView.reloadData()
			}
		}
	}
}

// MARK: - Events & Notifications

extension BasketViewController {
	
	func onButtonCurrenciesDidTap() {
		self.performSegue(withIdentifier: "CurrencyPickerSegue", sender: nil)
	}

	func onButtonDoneDidTap() {
		self.dismiss(animated: true, completion: nil)
	}
}
