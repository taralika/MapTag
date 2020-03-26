//
//  ServerAPI.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

import Foundation

let MAX_RECORDS = 100

class ServerAPI: NSObject
{
    struct Auth
    {
        static var sessionId: String? = nil
        static var key = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
    }
    
    enum Endpoints
    {
        static let baseURL = "https://onthemap-api.udacity.com/v1"
        
        case signup
        case login
        case getStudentLocations
        case addLocation
        case updateLocation
        case getLoggedInUserProfile
        
        var stringValue: String
        {
            switch self
            {
                case .signup:
                    return "https://auth.udacity.com/sign-up"
                case .login:
                    return Endpoints.baseURL + "/session"
                case .getStudentLocations:
                    return Endpoints.baseURL + "/StudentLocation?limit=\(MAX_RECORDS)&order=-updatedAt"
                case .addLocation:
                    return Endpoints.baseURL + "/StudentLocation"
                case .updateLocation:
                    return Endpoints.baseURL + "/StudentLocation/" + Auth.objectId
                case .getLoggedInUserProfile:
                    return Endpoints.baseURL + "/users/" + Auth.key
            }
        }
        
        var url: URL
        {
            return URL(string: stringValue)!
        }
    }
    
    override init()
    {
        super.init()
    }
 
    class func shared() -> ServerAPI
    {
        struct Singleton
        {
            static var shared = ServerAPI()
        }
        return Singleton.shared
    }
        
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    {
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        RequestHelpers.taskForPOSTRequest(url: Endpoints.login.url, apiType: "Udacity", responseType: LoginResponse.self, body: body, httpMethod: "POST")
        { (response, error) in
            if let response = response
            {
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                getLoggedInUserProfile(completion: { (success, error) in
                    if success
                    {
                        // do nothing
                    }
                })
                completion(true, nil)
            }
            else
            {
                completion(false, error)
            }
        }
    }
        
    class func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void)
    {
        RequestHelpers.taskForGETRequest(url: Endpoints.getLoggedInUserProfile.url, apiType: "Udacity", responseType: UserProfile.self)
        { (response, error) in
            if let response = response
            {
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            }
            else
            {
                completion(false, error)
            }
        }
    }
        
    class func logout(completion: @escaping () -> Void)
    {
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies!
        {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie
        {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            if error != nil
            {
                print("Error logging out.")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
        
    class func getStudentTags(completion: @escaping ([StudentInformation]?, Error?) -> Void)
    {
        RequestHelpers.taskForGETRequest(url: Endpoints.getStudentLocations.url, apiType: "Parse", responseType: StudentLocations.self)
        { (response, error) in
            if let response = response
            {
                completion(response.results, nil)
            }
            else
            {
                completion([], error)
            }
        }
    }
       
    class func addStudentTag(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void)
    {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        RequestHelpers.taskForPOSTRequest(url: Endpoints.addLocation.url, apiType: "Parse", responseType: PostLocationResponse.self, body: body, httpMethod: "POST")
        { (response, error) in
            if let response = response, response.createdAt != nil
            {
                Auth.objectId = response.objectId ?? ""
                completion(true, nil)
            }
            completion(false, error)
        }
    }
     
    class func updateStudentTag(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void)
    {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        RequestHelpers.taskForPOSTRequest(url: Endpoints.updateLocation.url, apiType: "Parse", responseType: UpdateLocationResponse.self, body: body, httpMethod: "PUT")
        { (response, error) in
            if let response = response, response.updatedAt != nil
            {
                completion(true, nil)
            }
            completion(false, error)
        }
    }
}
