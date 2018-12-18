//
//  CreatorViewController.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 14/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class CreatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var bbiTotal: UIBarButtonItem!
    
    @IBOutlet weak var tvRecipientInfo: UITextView!
    // UILabel
    @IBOutlet weak var nameSurname: UITextField!
    @IBOutlet weak var capCity: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var dueDate: UITextField!
    @IBOutlet weak var paymentMethod: UITextField!
    @IBOutlet weak var numberOfInvoice: UITextField!
    @IBOutlet weak var pdfFileName: UITextField!
    @IBOutlet weak var codiceFiscale: UITextField!
    @IBOutlet weak var pIva: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    
    //------------------------------------- variable
    
    var invoiceNumber: String!
    var items: [[String: String]]!
    var totalAmount = "0"
    var saveCompletionHandler: ((_ invoiceNumber: String, _ recipientInfo: String, _ totalAmount: String, _ items: [[String: String]]) -> Void)!
    
    var firstAppeared = true
    var nextNumberAsString: String!
    var senderInformation:String!
    
    
// -------------------------------------
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppeared {
            determineInvoiceNumber()
            displayTotalAmount()
            firstAppeared = false
            
           // print("What is sender information \(senderInformation)")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
 
  
    @IBAction func uploadImage(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    // delegate for UIImage
    
    // For image
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // To handle image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        self.logoImage.image = image
            // save the file in filemanager but i need to check if directory exist or not
            let fileManager = FileManager.default
            do {
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent("logo")
            
                if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    try imageData.write(to: fileURL)
                   
                }
            } catch {
                print("Error to save your image\(error)")
            }
        
        }
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: IBAction Methods
    
    @IBAction func addItem(_ sender: AnyObject) {
        let addItemViewController = storyboard?.instantiateViewController(withIdentifier: "idAddItem") as! AddItemViewController
        addItemViewController.presentAddItemViewControllerInViewController(originatingViewController: self) { (itemDescription, price) in
            
            DispatchQueue.main.async {
                if self.items == nil {
                    self.items = [[String: String]]()
                }
                
                self.items.append(["item": itemDescription, "price": price])
                
                self.displayTotalAmount()
            }
        }
    }
    
    
    @IBAction func saveInvoice(_ sender: AnyObject) {
        if saveCompletionHandler != nil {
            if nextNumberAsString != nil {
                UserDefaults.standard.set(nextNumberAsString, forKey: "nextInvoiceNumber")
            }
            else {
                UserDefaults.standard.set("002", forKey: "nextInvoiceNumber")
            }
            
            saveCompletionHandler(_: invoiceNumber, _:getSenderInfo() /*tvRecipientInfo.text*/, _: bbiTotal.title!, _: items)
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: Custom Methods
    
    func presentCreatorViewControllerInViewController(originalViewController: UIViewController, saveCompletionHandler: @escaping (_ invoiceNumber: String, _ recipientInfo: String, _ totalAmount: String, _ items: [[String: String]]) -> Void) {
        self.saveCompletionHandler = saveCompletionHandler
        originalViewController.navigationController?.pushViewController(self, animated: true)
    }
    
    
    func determineInvoiceNumber() {
        // Get the invoice number from the user defaults if exists.
        if let nextInvoiceNumber = UserDefaults.standard.object(forKey: "nextInvoiceNumber") {
            invoiceNumber = nextInvoiceNumber as! String
            
            // Save the next invoice number to the user defaults.
            let nextNumber = Int(nextInvoiceNumber as! String)! + 1
            
            if nextNumber < 10 {
                nextNumberAsString = "00\(nextNumber)"
            }
            else if nextNumber < 100 {
                nextNumberAsString = "0\(nextNumber)"
            }
            else {
                nextNumberAsString = "\(nextNumber)"
            }
        }
        else {
            // Specify the first invoice number.
            invoiceNumber = "001"
        }
        
        // Set the invoice number to the navigation bar's title.
        navigationItem.title = invoiceNumber
    }
    
    
    func calculateTotalAmount() {
        var total: Double = 0.0
        if items != nil {
            for invoiceItem in items {
                let priceAsNumber = NumberFormatter().number(from: invoiceItem["price"]!)
                total += Double(priceAsNumber!)
            }
        }
        
        totalAmount = AppDelegate.getAppDelegate().getStringValueFormattedAsCurrency(value: "\(total)")
    }
    
    
    func displayTotalAmount() {
        calculateTotalAmount()
        bbiTotal.title = totalAmount
    }
    
    
    func dismissKeyboard() {
        if tvRecipientInfo.isFirstResponder {
            tvRecipientInfo.resignFirstResponder()
        }
    }
    
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (items != nil) ? items.count : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath as IndexPath)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "itemCell")
        }
        
        cell.textLabel?.text = items[indexPath.row]["item"]
        cell.detailTextLabel?.text = AppDelegate.getAppDelegate().getStringValueFormattedAsCurrency(value: items[indexPath.row]["price"]!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            items.remove(at: indexPath.row)
            displayTotalAmount()
        }
    }
    
    
    
    
    
}



// Todo Invoice and date we will transfer in another part and payment method also and pdf file name also

extension CreatorViewController {
    
    func getSenderInfo() -> String{
        return "\(nameSurname.text!)<br>\(address.text!)<br>\(capCity.text!)<br>\(country.text!)<br>\(codiceFiscale.text!)<br>\(pIva.text!)"
    }
}
