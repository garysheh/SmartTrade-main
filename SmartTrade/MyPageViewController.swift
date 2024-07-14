//
//  MyPageViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/17.
//

import UIKit
import Firebase
import FirebaseFirestore

class MyPageViewController: UIViewController {
    @IBOutlet weak var marketData: UIButton!
    
    @IBOutlet weak var myRewards: UIButton!
    
    @IBOutlet weak var alerts: UIButton!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coupons: UIButton!
    
    @IBOutlet weak var history: UIButton!
    
    @IBOutlet weak var saved: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupInfo()
    }
    
    private func setupInfo() {
        let db = Firestore.firestore()
        guard let email = Auth.auth().currentUser?.email else {
            print("Error: email is nil")
            return
        }
        
        print("Email:", email)
        
        db.collection("UserInfo").document(email).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists {
                print("yes")
                let data = document.data()
                let UserID = (document.get("userID") as? Int32) ?? 0
                let name = document.get("FirstName") as? String
                
                DispatchQueue.main.async {
                    print("Name:", name ?? "N/A")
                    print("UserID:", UserID)
                    self.nameLabel.text = name ?? "N/A"
                    self.idLabel.text = "\(UserID)"
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func setupRoundedLabel(labels: [UILabel]) {
        for label in labels {
            label.layer.cornerRadius = 10 // Adjust the radius as needed
            label.layer.masksToBounds = true
        }
    }
    
    
    
    //Click the button then jump to corresponding page.
    @IBAction func HistoryButtonTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "HistoryOrderViewController") as? HistoryOrderViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
