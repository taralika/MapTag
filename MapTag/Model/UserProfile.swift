//
//  UserProfile.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

struct UserProfile: Codable
{
    let firstName: String
    let lastName: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey
    {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
}
