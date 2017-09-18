//
//  SettingsTableViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/14/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {


    @IBOutlet weak var chartLineWidthSlider: UISlider!
    
    @IBOutlet weak var chartLineWidthLabel: UILabel!
    
    @IBOutlet weak var smoothingSwitch: UISwitch!
    
    @IBOutlet weak var showValuesSwitch: UISwitch!
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartLineWidthSlider.value = Float(UserDefaults.standard.float(forKey: Defaults.ChartLineWidthKey))
        chartLineWidthLabel.text = numberFormatter.string(for: chartLineWidthSlider.value)
        smoothingSwitch.setOn(UserDefaults.standard.bool(forKey: Defaults.ChartCubicSmoothingKey), animated: false)
        showValuesSwitch.setOn(UserDefaults.standard.bool(forKey: Defaults.ChartShowValuesKey), animated: false)
    }


    @IBAction func setChartLineWidth(_ sender: Any) {
        UserDefaults.standard.set(chartLineWidthSlider.value, forKey: Defaults.ChartLineWidthKey)
        chartLineWidthLabel.text = numberFormatter.string(for: chartLineWidthSlider.value)
    }

    @IBAction func setSmoothing(_ sender: Any) {
        UserDefaults.standard.set(smoothingSwitch.isOn, forKey: Defaults.ChartCubicSmoothingKey)
    }
    
    @IBAction func setShowValues(_ sender: Any) {
        UserDefaults.standard.set(showValuesSwitch.isOn, forKey: Defaults.ChartShowValuesKey)
        
    }
    
    // MARK: - Table view data source
/*
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
 */
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
