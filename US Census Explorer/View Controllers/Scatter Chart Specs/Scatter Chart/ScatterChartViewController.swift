//
//  ScatterChartViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 9/26/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import Charts
import RxSwift
import Photos

// This class is responsible for coordinating the display of the scatter chart view.
// It also handles the ability to save an image of the chart to the users photos

class ScatterChartViewController: UIViewController, ChartViewDelegate, StoryboardInitializable {
    
    let disposeBag = DisposeBag()

    @IBOutlet private weak var chartView: CensusScatterChartView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let authorized = PHPhotoLibrary.authorized.share()
    
    var viewModel: ScatterChartViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chartView.configure(withViewModel: viewModel)
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
