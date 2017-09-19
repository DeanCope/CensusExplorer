//
//  HelpViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/18/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func linkToCensusBureau(_ sender: Any) {
        if let url = URL(string: "https://www.census.gov/"){
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    @IBAction func linkToIcons8(_ sender: Any) {
        if let url = URL(string: "https://icons8.com/"){
           UIApplication.shared.open(url, options: [:])        }
    }
    @IBAction func linkToChartsFramework(_ sender: Any) {
        if let url = URL(string: "https://github.com/danielgindi/Charts"){
            UIApplication.shared.open(url, options: [:])        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
