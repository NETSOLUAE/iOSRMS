//
//  WebserviceManager.swift
//  RMS
//
//  Created by Mac Mini on 8/20/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import UIKit
import Foundation

class WebserviceManager: NSObject {
    let constants = Constants();
    
    func login(type: String, endPoint: String, completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        let urlString = endPoint
        
        guard let url = URL(string: urlString) else { return completion(.Error(constants.errorMessage)) }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    let status = json["status"] as! String
                    if (type == "single") {
                        let message = json["message"] as! String
                        if (status == "success"){
                            guard let itemsJsonArray = json["data"] as? [String: AnyObject] else {
                                if (message != "") {
                                    return completion(.Error(message))
                                } else {
                                    return completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                                }
                            }
                            DispatchQueue.main.async {
                                completion(.SuccessSingle(itemsJsonArray, message))
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.async {
                                completion(.Error(message))
                            }
                        }
                    } else if (type == "contact") {
                        guard let itemsJsonArray = json["data"] as? [[String: AnyObject]] else {
                        return completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                        }
                        if (status == "success"){
                            DispatchQueue.main.async {
                                completion(.SuccessContact(itemsJsonArray))
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.async {
                                completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                            }
                        }
                    } else if (type == "ebPolicy") {
                        var require_update = ""
                        if (json["require_update"] != nil){
                            require_update = json["require_update"] as! String
                        }
                        guard let itemsJsonArray = json["data"] as? [String: AnyObject] else {
                            return completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                        }
                        if (status == "success"){
                            DispatchQueue.main.async {
                                completion(.SuccessSingle(itemsJsonArray, require_update))
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.async {
                                completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                            }
                        }
                    } else {
                        var require_update = ""
                        if (json["require_update"] != nil){
                            require_update = json["require_update"] as! String
                        }
                        guard let itemsJsonArray = json["data"] as? [[String: AnyObject]] else {
                            return completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                        }
                        if (status == "success"){
                            DispatchQueue.main.async {
                                completion(.Success(itemsJsonArray, require_update))
                            }
                        } else if (status == "fail") {
                            DispatchQueue.main.async {
                                completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                            }
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.Error(error?.localizedDescription ?? self.constants.errorMessage))
                    }
                }
            } catch let error {
                print("Localised Error \(error)")
                return completion(.Error(self.constants.errorMessage))
            }
            }.resume()
    }
    
}

enum Result<T> {
    case SuccessSingle([String: AnyObject], String)
    case SuccessContact([[String: AnyObject]])
    case Success([[String: AnyObject]], String)
    case Error(String)
}
