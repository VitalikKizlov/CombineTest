//
//  FormViewController.swift
//  CombineTest
//
//  Created by Vitalii Kizlov on 08.07.2020.
//  Copyright © 2020 Vitalii Kizlov. All rights reserved.
//

import UIKit
import Combine

class FormViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var value1_input: UITextField!
    @IBOutlet weak var value2_input: UITextField!
    @IBOutlet weak var value2_repeat_input: UITextField!
    @IBOutlet weak var submission_button: UIButton!
    @IBOutlet weak var value1_message_label: UILabel!
    @IBOutlet weak var value2_message_label: UILabel!
    
    // MARK: - Internal Properties
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
