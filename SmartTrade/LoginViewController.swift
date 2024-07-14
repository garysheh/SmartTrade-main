//
//  LoginViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/4/30.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
                    showAlert(title: "Error", message: "Please enter an email address.")
                    return
                }

                guard let password = passwordTextField.text, !password.isEmpty else {
                    showAlert(title: "Error", message: "Please enter a password.")
                    return
                }

                Auth.auth().signIn(withEmail: email, password: password) { [weak self] firebaseResult, error in
                    if let error = error {
                        showAlert(title: "Login Failed", message: error.localizedDescription)
                    } else {
                        self?.performSegue(withIdentifier: "goToNext", sender: self)
                    }
                }
        
    func showAlert(title: String, message: String) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let email = emailTextField.text else {return}
//        if segue.identifier == "goToNext"{
//            if let secondVC = segue.destination as? WatchListViewController, let emailID = sender as? String{
//                secondVC.emailID = email
//            }
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
