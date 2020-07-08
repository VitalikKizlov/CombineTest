//
//  ViewController.swift
//  CombineTest
//
//  Created by Vitalii Kizlov on 06.07.2020.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import UIKit
import Combine
import Contacts

struct IPInfo: Codable {
    var ip: String
}

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var step1_button: UIButton!
    @IBOutlet weak var step2_1_button: UIButton!
    @IBOutlet weak var step2_2_button: UIButton!
    @IBOutlet weak var step2_3_button: UIButton!
    @IBOutlet weak var step3_button: UIButton!
    @IBOutlet weak var step4_button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Internal Properties
    
    var cancelable: AnyCancellable?
    var coordinatedPipeline: AnyPublisher<Bool, Error>?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPipeline()
    }
    
    // MARK: - Actions

    @IBAction func doit(_ sender: Any) {
        run()
    }
    
    // MARK: - Private
    
    private func setupPipeline() {
        coordinatedPipeline = createFuturePublisher(button: step1_button)
            .flatMap({ (flatMapValue) -> AnyPublisher<Bool, Error> in
                let step21 = self.createFuturePublisher(button: self.step2_1_button)
                let step22 = self.createFuturePublisher(button: self.step2_2_button)
                let step23 = self.createFuturePublisher(button: self.step2_3_button)
                return Publishers.Zip3(step21, step22, step23)
                .map { _ -> Bool in
                    return true
                }
            .eraseToAnyPublisher()
            })
            .flatMap({ _ in
                return self.createFuturePublisher(button: self.step3_button)
            })
            .flatMap({ _ in
                return self.createFuturePublisher(button: self.step4_button)
            })
        .eraseToAnyPublisher()
    }
    
    private func run() {
        if cancelable != nil {
            cancelable?.cancel()
            activityIndicator.stopAnimating()
        }
        resetAllSteps()
        activityIndicator.startAnimating()
        cancelable = coordinatedPipeline?.sink(receiveCompletion: { (completion) in
            print("completion ----- \(completion)")
            self.activityIndicator.stopAnimating()
        }, receiveValue: { (value) in
            print("receive value ----- \(value)")
        })
    }
    
    private func randomAsyncApi(completion: @escaping (Bool, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            sleep(UInt32.random(in: 1...4))
            completion(true, nil)
        }
    }
    
    private func createFuturePublisher(button: UIButton) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.randomAsyncApi { (success, error) in
                if let err = error {
                    promise(.failure(err))
                }
                promise(.success(success))
            }
        }
        .receive(on: DispatchQueue.main)
        .map({ (value) -> Bool in
            self.markStepDone(button: button)
            return true
        })
        .eraseToAnyPublisher()
    }
    
    private func markStepDone(button: UIButton) {
        button.backgroundColor = .systemGreen
        button.isHighlighted = true
    }

    private func resetAllSteps() {
        for button in [self.step1_button, self.step2_1_button, self.step2_2_button, self.step2_3_button, self.step3_button, self.step4_button] {
            button?.backgroundColor = .lightGray
            button?.isHighlighted = false
        }
        self.activityIndicator.stopAnimating()
    }

}

