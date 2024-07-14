//
//  RegisterViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/4/30.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation
import CoreData

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let firstname = FirstNameTextField.text else {return}
        guard let lastname = LastNameTextField.text else {return}
        
        
        //Core Data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        Auth.auth().createUser(withEmail:email, password: password) { firebaseResult, error in
            if let e = error{
                self.showNoSignUp()
            }
            else{
                let db = Firestore.firestore()
                let uuid = UUID()
                let userID: Int32 = 100000000
                
                db.collection("UserIDCounter").document("counter").getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let currentUserID = (document.get("userID") as? Int32) ?? 0
                        let newUserID = currentUserID + 1
                        
                        // 更新 UserIDCounter 文档
                        db.collection("UserIDCounter").document("counter").setData(["userID": newUserID], merge: true)

                        
                        //Firebase
                        db.collection("UserInfo").document(email).setData([
                            "FirstName": firstname,
                            "LastName": lastname,
                            "UUID": uuid.uuidString,
                            "email":email,
                            "password":password,
                            "userID": newUserID
                        ])
                        db.collection("Holdings").document(email).setData([
                            "email":email,
                            "balance": 500000,
                            "cost": 0,
                            "holdings":[
                                ["stockCode":"AAPL","shares":50,"avgCost":50],
                                ["stockCode":"AMZN","shares":100,"avgCost":50]]
                        ])
                        //testing by setting default number
                        
                        
                        //CoreData
                        
                        let newUser = User(context: context)
                        
                        newUser.balance = 0
                        newUser.userID = newUserID
                        newUser.verifyID = uuid
                        newUser.email = email
                        newUser.password = password
                        
                        do {
                            try context.save()
                            print(NSPersistentContainer.defaultDirectoryURL())
                        } catch {
                            print("Error saving user: \(error)")
                        }
                        
                        self.showSignUp()
                    }
                }
                
            }
        }
    
    }
    
    func showSignUp(){
        let alert = UIAlertController(title: "Successful!", message: "Welcome to SmartTrade!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start!", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showNoSignUp(){
        let alert = UIAlertController(title: "Unsuccessful:(", message: "The password needs to be 6 characters or more. If the conditions are met, it may be that this email address has already been registered.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try agian", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
