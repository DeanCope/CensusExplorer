//
//  LineChartViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/23/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//
import UIKit
import Charts
import RxSwift
import Photos

// This class is responsible for coordinating the display of the line chart view.
// It also handles the ability to save an image of the chart to the users photos

class LineChartViewController: UIViewController, StoryboardInitializable {
    
    let disposeBag = DisposeBag()

    @IBOutlet weak var chartView: CensusLineChartView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let authorized = PHPhotoLibrary.authorized.share()
    
    var viewModel: LineChartViewModel!
    
    var settingsExpanded = false
    var settingsViewController: SettingsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.refreshSettings()
        chartView.configure(withViewModel: viewModel)
        
    }
    private func setUpUI() {
        view.addSubview(settingsViewController.view)
        settingsViewController.view.layer.shadowOpacity = 0.8
        addChildViewController(settingsViewController)
        settingsViewController.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height / 2)
        settingsViewController.didMove(toParentViewController: self)
    }
    
    
    private func bindViewModel() {
        
        // Inputs from ViewModel to UI
        viewModel.noDataText
            .drive(chartView.rx.noDataText)
            .disposed(by: disposeBag)
        
        viewModel.titleText
            .drive(chartView.titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.xAxisText
            .drive(chartView.rx.xAxisLabel)
            .disposed(by: disposeBag)
        
        viewModel.needsDisplay
            .drive(chartView.rx.needsDisplay)
            .disposed(by: disposeBag)
        
        settingsViewController.viewModel.didRequestClose
            .subscribe(onNext: { [weak self] in
                self?.toggleSettings(self as Any)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func toggleSettings(_ sender: Any) {
        animateSettingsPanel(shouldExpand: !settingsExpanded)
    }
    
    func animateSettingsPanel(shouldExpand: Bool) {
        if shouldExpand {
            settingsExpanded = true
            animateSettingsPanelYPosition(
                targetPosition: view.frame.height - view.frame.height / 2)
        } else {
            animateSettingsPanelYPosition(targetPosition: view.frame.height) { finished in
                self.settingsExpanded = false
                //self.settingsViewController.view.removeFromSuperview()
                //self.leftViewCOntroller = nil
            }
        }
    }
    
    func animateSettingsPanelYPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.settingsViewController.view.frame.origin.y = targetPosition
        }, completion: completion)
    }
    
    private func errorMessage() {
        alert(title: "No access to Camera Roll",
              text: "You can grant access from the Settings app")
            // Only display for a maximum of 5 seconds...
            .take(5.0, scheduler: MainScheduler.instance)
            .subscribe(onDisposed: {[weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        
        // Display an error message if the user doesn't grant access
        authorized
            .skip(1)
            .takeLast(1)
            .filter { $0 == false }
            .subscribe(onNext: { [weak self] _ in
                guard let errorMessage = self?.errorMessage else {return}
                DispatchQueue.main.async(execute: errorMessage)
            })
            .disposed(by: disposeBag)
        
        // Save to camera roll if the user has granted access
        authorized
            .skipWhile { $0 == false }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                // https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
                if self != nil {
                    UIImageWriteToSavedPhotosAlbum(self!.chartView.getChartImage(transparent: false)!, self!, #selector(self!.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            // we got back an error!
            alert(message: "No access to Camera Roll: You can grant access from the Settings app") // \(error)")
        } else {
            alert(title: "Saved!", message: "The chart image has been saved to your photos.")
        }
    }
}
