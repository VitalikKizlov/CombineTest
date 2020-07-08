//
//  GithubAPI.swift
//  CombineTest
//
//  Created by Vitalii Kizlov on 07.07.2020.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import Foundation
import Combine

enum APIFailureCondition: Error {
    case invalidServerResponse
}

struct GithubAPI {
    static let networkActivityPublisher = PassthroughSubject<Bool, Never>()
    
    static func retrieveUser(by username: String) -> AnyPublisher<[GithubAPIUser], Never> {
        guard username.count > 3 else {
            return Just([]).eraseToAnyPublisher()
        }
        
        let assembledURL = String("https://api.github.com/users/\(username)")
        let url = URL(string: assembledURL)!
        
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(receiveSubscription: { _ in
                networkActivityPublisher.send(true)
            }, receiveCompletion: { (completion) in
                networkActivityPublisher.send(false)
            }, receiveCancel: {
                networkActivityPublisher.send(false)
            })
            .tryMap { (data, response) in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw APIFailureCondition.invalidServerResponse
                }
                return data
        }
        .decode(type: GithubAPIUser.self, decoder: JSONDecoder())
            .map {
                [$0]
        }
        .replaceError(with: [])
        .eraseToAnyPublisher()
        
        return publisher
    }
}
