//
//  GameEndViewController.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/17/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit

class GameEndViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func playAgain(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
