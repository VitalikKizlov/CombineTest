//
//  GithubAPIUser.swift
//  CombineTest
//
//  Created by Vitalii Kizlov on 07.07.2020.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import Foundation

struct GithubAPIUser: Decodable {
    // A very *small* subset of the content available about
    //  a github API user for example:
    // https://api.github.com/users/heckj
    let login: String
    let public_repos: Int
    let avatar_url: String
}
