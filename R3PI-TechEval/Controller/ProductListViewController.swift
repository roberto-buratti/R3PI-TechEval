//
//  ProductListViewController.swift
//  R3PI-TechEval
//
//  Created by Roberto O. Buratti on 11/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import UIKit

class ProductListViewController: UITableViewController {
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Better than Amazon ;)"
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
		
		let buttonBasket = UIButton(type: UIButtonType.custom)
		buttonBasket.setImage(UIImage(named:"basket"), for: UIControlState.normal)
		buttonBasket.showsTouchWhenHighlighted = true
		buttonBasket.addTarget(self, action:#selector(onButtonBasketDidTap), for: UIControlEvents.touchUpInside)
		buttonBasket.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonBasket)
		
		NotificationCenter.default.addObserver(self,
		                                       selector:#selector(onNotificationProductsAvailable),
		                                       name: Notification.Name(rawValue: Basket.kNotificationProductsAvailable),
		                                       object:nil)
		
        // Do any additional setup after loading the view.
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
		}
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ProductListViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let basket = Basket.sharedInstance
		return basket.products.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return " "
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell", for: indexPath)
		let basket = Basket.sharedInstance
		let product = basket.products[indexPath.row]
		
		cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
		cell.imageView?.image = UIImage(named: product.imageName)
		cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
		cell.imageView?.layer.borderWidth = 1
		cell.textLabel?.text = product.title
		
		let qty = basket.quantity(forProduct: product)
		if (qty > 0) {
			cell.detailTextLabel?.text = "\(qty) \(product.unit)(s) in basket x \(product.price) \(basket.defaultCurrency)"
			cell.detailTextLabel?.textColor = self.navigationController?.navigationBar.barTintColor
			cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
		} else {
			cell.detailTextLabel?.text = "\(product.price) \(basket.defaultCurrency) per \(product.unit)"
			cell.detailTextLabel?.textColor = UIColor.gray
			cell.detailTextLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.layoutIfNeeded()
		cell.imageView?.layer.masksToBounds = true;
		cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let basket = Basket.sharedInstance
		let product = basket.products[indexPath.row]
		self.performSegue(withIdentifier: "ProductSegue", sender: product)
	}
}

// MARK: - Events & Notifications

extension ProductListViewController {
	
	func onNotificationProductsAvailable() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	func onButtonBasketDidTap() {
		self.performSegue(withIdentifier: "BasketSegue", sender: nil)		
	}
}
