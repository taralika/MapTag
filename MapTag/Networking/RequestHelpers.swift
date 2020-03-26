//
//  RequestHelpers.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import Foundation

let TIMEOUT_INTERVAL = 30

class RequestHelpers
{
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, apiType: String, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void)
    {
        var request = URLRequest(url: url)
        request.timeoutInterval = TimeInterval(TIMEOUT_INTERVAL)
        request.httpMethod = "GET"
        
        if apiType == "Udacity"
        {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        else
        {
            request.addValue(Constants.APP_ID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error  in
            if error != nil
            {
                completion(nil, error)
            }
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
            do
            {
                if apiType == "Udacity"
                {
                    let range = 5..<data.count
                    let newData = data.subdata(in: range)
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async
                    {
                        completion(responseObject, nil)
                    }
                }
                else
                {
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                    DispatchQueue.main.async
                    {
                        completion(responseObject, nil)
                    }
                }
            }
            catch
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
        
    class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, apiType: String, responseType: ResponseType.Type, body: String, httpMethod: String, completion: @escaping (ResponseType?, Error?) -> Void)
    {
        var request = URLRequest(url: url)
        request.timeoutInterval = TimeInterval(TIMEOUT_INTERVAL)
        if httpMethod == "POST"
        {
            request.httpMethod = "POST"
        }
        else
        {
            request.httpMethod = "PUT"
        }
        
        if apiType == "Udacity"
        {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        else
        {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.httpBody = body.data(using: String.Encoding.utf8)
       
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil
            {
                completion(nil, error)
            }
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
            do
            {
                if apiType == "Udacity"
                {
                    let range = 5..<data.count
                    let newData = data.subdata(in: range)
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async
                    {
                        completion(responseObject, nil)
                    }
                }
                else
                {
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                    DispatchQueue.main.async
                    {
                        completion(responseObject, nil)
                    }
                }
            }
            catch
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
