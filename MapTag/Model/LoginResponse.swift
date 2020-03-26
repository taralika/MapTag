//
//  LoginResponse.swift
//  MapTag
//
//  Created by taralika on 2/19/20.
//  Copyright © 2020 at. All rights reserved.
//

struct LoginResponse: Codable
{
    let account: Account
    let session: Session
}

struct Account: Codable
{
    let registered: Bool
    let key: String
}
