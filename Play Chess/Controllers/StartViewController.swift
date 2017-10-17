//
//  StartViewController.swift
//  Play Chess
//
//  Created by Aditya Emani on 10/16/17.
//  Copyright © 2017 Aditya Emani. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ViewController
        
        if segue.identifier == "singlePlayer"{
            destinationVC.isAgainstAI = true
        }else if segue.identifier == "multiPlayer"{
            destinationVC.isAgainstAI = false
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue){
        
    }
}
