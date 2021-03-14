//
//  APIService.swift
//  Britannia
//
//  Created by Admin on 16/02/21.
//

import Foundation

class APIService: NSObject {
    
    let baseURL = "http://35.194.23.15:7197/"  // Replace Base URL
    
    // Path of the URL
    func apiSuffix(name: String, parameters:[Any])-> String {
        switch name {
        case "Departments":
            return baseURL + "departments"
            
        case "Reports":
            if parameters.count > 0 {
                return baseURL + "reports?department=\(parameters[0])"
            } else {
                return baseURL + "reports"
            }
            
        case "ReportsAdd":
            return baseURL + "addreports"
            
        case "DeleteReports" :
            return baseURL + "deletereports"
            
        default:
            return baseURL + "departments"
        }
    }
    
    
    func connect (name: String, parameters:[Any], completion:@escaping (Data?, HTTPURLResponse?) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: apiSuffix(name: name, parameters: parameters))! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        
        switch name {
        case "ReportsAdd" :
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            let dict = Dictionary(dictionaryLiteral: ("department_name",parameters[0]),("reports",parameters[1]))
            
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: .sortedKeys)
                request.httpBody = data
            } catch let error {
                print("error",error)
            }
            break
            
        case "DeleteReports" :
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            let dict = Dictionary(dictionaryLiteral: ("ids",parameters))
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: dict, options: [])
            } catch let error {
                print("error",error)
            }
            break
        default:
            request.httpMethod = "GET"
            break
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        completion(data!, httpResponse)
                    }
                }
            }
        })

        dataTask.resume()
    }
}
