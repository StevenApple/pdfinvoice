//
//  RecipientInfoViewController.swift
//  Print2PDF
//
//  Created by Steven M on 08/12/2018.
//  Copyright © 2018 Appcoda. All rights reserved.
//

import UIKit

class RecipientInfoViewController: UIViewController {
    
    
    @IBOutlet weak var nameAndSurname: UITextField!
    @IBOutlet weak var capAndCity: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var duedate: UITextField!
    @IBOutlet weak var paymentMethod: UITextField!
    @IBOutlet weak var InvoiceNumber: UITextField!
    @IBOutlet weak var Piva: UITextField!
    @IBOutlet weak var CodiceFiscale: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func insertedallinformationForReciepient () -> String {
        return "\(String(describing: self.nameAndSurname.text!))<br>\(String(describing: self.capAndCity.text!))<br>\(String(describing: self.address.text!))<br>\(String(describing: self.country.text!))<br>\(String(describing: self.duedate.text!))<br>\(String(describing: self.paymentMethod.text!))<br>\(String(describing: self.InvoiceNumber.text!))<br>\(String(describing: self.Piva.text!))<br>\(String(describing: self.CodiceFiscale.text!))"
    }
 
    
    func passValuetoCreatorViewcontroller(){
        let allInfo = self.insertedallinformationForReciepient()
        print(allInfo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "senderToreciepent"{
            let detVC : CreatorViewController = segue.destination as! CreatorViewController
            detVC.senderInformation = self.insertedallinformationForReciepient()
        }
    }
    
    
    @IBAction func passValueAction(_ sender: Any) {
        
        self.passValuetoCreatorViewcontroller()

    }
    
}

