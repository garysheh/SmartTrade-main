//
//  PlaceSuccessfullyViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/28.
//

import UIKit

class PlaceSuccessfullyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
        // Do any additional setup after loading the view.
    }

    private func setupTapGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            view.addGestureRecognizer(tapGesture)
        }
        
        @objc private func handleTapGesture() {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainViewController = storyboard.instantiateViewController(withIdentifier: "DetailPositionDataViewController") as? DetailPositionDataViewController {
                navigationController?.pushViewController(mainViewController, animated: true)
            }
        }

}
