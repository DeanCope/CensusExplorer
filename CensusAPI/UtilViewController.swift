//
//  UtilViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/18/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class UtilViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        numberOfValuesLabel.text = String(CensusDataSource.sharedInstance().countCensusValues())
    }

    @IBOutlet weak var numberOfValuesLabel: UILabel!
    @IBAction func clearCachedData(_ sender: Any) {
        CensusDataSource.sharedInstance().deleteAllCensusValues()
        alert(message: "The census values have been deleted.  They will automatically be reloaded from the server if/when you return to the Census Topics page.")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
