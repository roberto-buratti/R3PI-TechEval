//
//  ProductViewController.swift
//  R3PI-TechEval
//
//  Created by Roberto O. Buratti on 11/06/2017.
//  Copyright © 2017 Roberto O. Buratti. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController,UITextFieldDelegate {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var labelPrice: UILabel!
	@IBOutlet weak var textFieldQty: UITextField!
	@IBOutlet weak var stepperQty: UIStepper!
	@IBOutlet weak var buttonAddToBasket: UIButton!
	@IBOutlet weak var buttonRemoveFromBasket: UIButton!
	
	var product:Product? {
		didSet {
			self.title = self.product?.title
			if (self.isViewLoaded) {
				self.prime()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.imageView.layer.borderColor = UIColor.lightGray.cgColor
		self.imageView.layer.borderWidth = 1
		self.imageView.layer.masksToBounds = true;
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)

		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(onKeyboardWillShow(notification:)),
		                                       name: NSNotification.Name.UIKeyboardWillShow,
		                                       object: nil)
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(onKeyboardDidHide(notification:)),
		                                       name: NSNotification.Name.UIKeyboardDidHide,
		                                       object: nil)
		
		self.prime()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.imageView.layoutIfNeeded()
		self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
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

// MARK: - UITextFieldDelegate

extension ProductViewController {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		self.refreshStatus(button:self.buttonAddToBasket, enabled: false)
		let oldText = textField.text ?? ""
		let newText = (oldText as NSString).replacingCharacters(in: range, with: string)
		var qty = Int(newText)
		guard (newText.characters.count == 0 || qty != nil) else {
			return false
		}
		if (qty == nil) {
			qty = 0
		}
		guard Double(qty!) <= self.stepperQty.maximumValue else {
			return false
		}
		guard Double(qty!) >= self.stepperQty.minimumValue else {
			return false
		}
		self.stepperQty.value = Double(qty!)
		self.refreshStatus(button: self.buttonAddToBasket, enabled: self.stepperQty.value > 0)
		let basket = Basket.sharedInstance
		if (basket.contains(product: self.product!)) {
			basket.add(product: self.product!, quantity: Int(self.stepperQty.value))
		}
		return true
	}
}

// MARK: - Events & Notifications

extension ProductViewController {
	
	@IBAction func onStepperQtyDidChangeValue() {
		self.textFieldQty.text = "\(Int(self.stepperQty.value))"
		self.refreshStatus(button:self.buttonAddToBasket, enabled:self.stepperQty.value > 0)
		let basket = Basket.sharedInstance
		if (basket.contains(product: self.product!)) {
			basket.add(product: self.product!, quantity: Int(self.stepperQty.value))
		}
	}
	
	@IBAction func  onButtonAddToBasketDidTap() {
		let basket = Basket.sharedInstance
		basket.add(product:self.product!, quantity:Int(self.stepperQty.value))
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func  onButtonRemoveFromBasketDidTap() {
		let alert:UIAlertController = UIAlertController(title: "Confirm remove",
		                                                message: "Are you sure you want to remove this product from the basket?",
		                                                preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Yes, remove it", style: UIAlertActionStyle.destructive, handler: { (alert:UIAlertAction) in
			let basket = Basket.sharedInstance
			basket.remove(product: self.product!)
			self.navigationController?.popViewController(animated: true)
		}))
		alert.addAction(UIAlertAction(title: "Never mind", style: UIAlertActionStyle.cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func onKeyboardWillShow(notification:Notification) {
		if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			var contentInset = self.scrollView.contentInset
			contentInset.top -= keyboardFrame.height
			self.scrollView.contentInset = contentInset
		}
	}

	func onKeyboardDidHide(notification:Notification) {
		self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
	}
}

// MARK: - Private methods

extension ProductViewController {
	
	func refreshStatus(button:UIButton, enabled:Bool) {
		button.isEnabled = (enabled && self.product != nil)
		button.alpha = self.buttonAddToBasket.isEnabled ? 1.0 : 0.4
	}
	
	func prime() {
		if let product = self.product {
			let basket = Basket.sharedInstance
			self.imageView.image = UIImage(named: product.imageName)
			self.labelPrice.text = "\(product.price) \(basket.defaultCurrency) per \(product.unit)"
			self.refreshStatus(button:self.buttonAddToBasket, enabled: true)
			let qty = basket.quantity(forProduct: product)
			self.textFieldQty.text = "\(qty)"
			self.stepperQty.value = Double(qty)
			self.refreshStatus(button:self.buttonAddToBasket, enabled: self.stepperQty.value > 0)
			if (basket.contains(product: self.product!)) {
				self.buttonAddToBasket.isHidden = true
				self.buttonRemoveFromBasket.isHidden = false
			} else {
				self.buttonAddToBasket.isHidden = false
				self.buttonRemoveFromBasket.isHidden = true
			}
		} else {
			self.imageView.image = nil
			self.labelPrice.text = nil
			self.refreshStatus(button:self.buttonAddToBasket, enabled: false)
		}
	}
}
