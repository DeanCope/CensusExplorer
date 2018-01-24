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

class ScatterChartViewController: UIViewController, ChartViewDelegate, StoryboardInitializable {
    
    let disposeBag = DisposeBag()

    @IBOutlet private weak var chartView: CensusScatterChartView!
    
    let authorized = PHPhotoLibrary.authorized.share()
    
    var viewModel: ScatterChartViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chartView.configure(withViewModel: viewModel)
    }
    
    // ??? Add save to camera roll
}
