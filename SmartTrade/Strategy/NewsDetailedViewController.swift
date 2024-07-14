//
//  NewsDetailedViewController.swift
//  SmartTrade
//
//  Created by Frank Leung on 13/7/2024.
//

import UIKit
import WebKit
import Foundation


class NewsDetailedViewController: UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var testButton: UIButton!
    var articleURL: URL?
    var articleTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.configuration.mediaTypesRequiringUserActionForPlayback = .all
        webview.layer.cornerRadius = 15
        guard let url = articleURL else {
            return
        }
        let request = URLRequest(url: url)
        webview.load(request)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func testButtonTapped(_ sender: Any) {
        guard let url = URL(string: "https://api-inference.huggingface.co/models/ProsusAI/finbert") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "inputs": articleTitle
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var retryCount = 0
            
            func makeRequest() {
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        retryCount += 1
                        if retryCount < 2 {
                            print("Retrying in 5 seconds...")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                makeRequest()
                            }
                        } else {
                            print("Failed to make request after 2 retries.")
                        }
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                        print("Server responded with an error")
                        retryCount += 1
                        if retryCount < 2 {
                            print("Retrying in 5 seconds...")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                makeRequest()
                            }
                        } else {
                            DispatchQueue.main.async {
                                                    let alert = UIAlertController(title: "Oops..", message: "Try again!", preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Alright", style: .default, handler: nil))
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                        }
                        return
                    }
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            print("\(json)")
                            if let jsonString = String(data: try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8) {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: [])
                                    
                                    if let outerArray = json as? [[Any]] {
                                        if let innerArray = outerArray.first as? [[String: Any]] {
                                            var maxScore = 0.0
                                            var maxLabel = ""
                                            for item in innerArray {
                                                if let label = item["label"] as? String,
                                                   let score = item["score"] as? Double {
                                                    if score > maxScore {
                                                        maxScore = score
                                                        maxLabel = label
                                                    }
                                                }
                                            }
                
                                            DispatchQueue.main.async {
                                                let alert = UIAlertController(title: "\(maxLabel.uppercased())", message: "According to the FinBert, this maybe is \(maxLabel). The result is for reference only!", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                self.present(alert, animated: true, completion: nil)
                                                                }
                                        }
                                    }
                                } catch {
                                    print("Error decoding JSON: \(error)")
                                }
                            }
                        }
                        //json
                        catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
                task.resume()
            }
            makeRequest()
        }
        task.resume()
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
