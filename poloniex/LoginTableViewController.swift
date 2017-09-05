//
//  LoginTableViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 8/28/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {

    @IBOutlet weak var loginBttnOutlet: UIButton!
    
    func setUpLognInBttn() {
        loginBttnOutlet.layer.cornerRadius = 8.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLognInBttn()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath) as! LoginCell
        
        if indexPath.row == 0 {
            cell.descriptionLabel.text = "Key"
        } else {
            cell.descriptionLabel?.text = "Secret"
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "KEY and SECRET"
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    
    @IBAction func loginBttn(_ sender: UIButton) {
        login(sender)
    }
    
    func login(_ sender: UIButton) {
        
        print("login")
        
        let keyCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LoginCell
        let secretCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! LoginCell
        
        
        
        if let key:String = keyCell.inputTextField.text, let secret:String = secretCell.inputTextField.text {
            if key != "" {
                keyCell.inputTextField.backgroundColor = UIColor.white
                UserDefaults.standard.set(key, forKey: "key")
                print("the saved key is \(key)")
            } else {
                keyCell.inputTextField.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            }
            
            if secret != "" {
                secretCell.inputTextField.backgroundColor = UIColor.white
                UserDefaults.standard.set(secret, forKey: "secret")
                print("the saved secret is: \(secret)")
            } else {
                secretCell.inputTextField.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            }
            
            if key != "" && secret != "" {
                dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
}
