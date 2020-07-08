//
//  GithubViewController.swift
//  CombineTest
//
//  Created by Vitalii Kizlov on 07.07.2020.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import UIKit
import Combine

class GithubViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var github_id_entry: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var githubAvatarImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    
    
    // MARK: - Internal Properties
    
    private var usernameSubscriber: AnyCancellable?
    private var networkActivitySubscriber: AnyCancellable?
    private var countSubscriber: AnyCancellable?
    
    @Published var username = ""
    @Published private var userData: [GithubAPIUser] = []
    private let queue = DispatchQueue(label: "username", qos: .background)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        github_id_entry.delegate = self
        setupUserNameSubscriber()
        setupNetworkActivitySubscriber()
        setupGitHubCountSubscriber()
        
        // KVO publisher of UIKit interface element
        let _ = countLabel.publisher(for: \.text)
            .sink { someValue in
                print("repositoryCountLabel Updated to \(String(describing: someValue))")
            }
    }
    
    private func setupUserNameSubscriber() {
        usernameSubscriber = $username
            .throttle(for: 0.5, scheduler: queue, latest: true)
            .removeDuplicates()
            .map({ (username) -> AnyPublisher<[GithubAPIUser], Never> in
                return GithubAPI.retrieveUser(by: username)
            })
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: \.userData, on: self)
    }
    
    private func setupNetworkActivitySubscriber() {
        networkActivitySubscriber = GithubAPI.networkActivityPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (workInProgress) in
                if workInProgress {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            })
    }
    
    private func setupGitHubCountSubscriber() {
        countSubscriber = $userData
            .map({ (array) in
                if let firstUser = array.first {
                    return String(firstUser.public_repos)
                }
                return "unknown"
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: countLabel)
    }
    
}

// MARK: - UITextFieldDelegate
extension GithubViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        username = textField.text ?? ""
        return true
    }
}
