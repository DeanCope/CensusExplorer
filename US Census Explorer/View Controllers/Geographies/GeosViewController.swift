//
//  GeosViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 6/6/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Instructions

// This class is responsible for displaying the grouped, multiple-select list of geographies (USA + States)
// for the user to choose from.
// It is used by both the Line Chart and Scatter Chart.
// The results of the user selection(s) are stored in Core Data, using the "selected" flag on each Geo.
    
class GeosViewController: UIViewController, UITableViewDelegate, StoryboardInitializable {
    
    let disposeBag = DisposeBag()
    
    var viewModel: GeosViewModel!
    
    @IBOutlet private weak var instructionsLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var graphItButton: UIBarButtonItem!
    @IBOutlet private weak var selectAllButton: UIButton!
    @IBOutlet private weak var deselectAllButton: UIButton!
    
    var coachMarksController = CoachMarksController()
    let introText = "Select one or more geographies."
    let graphItText = "Tap 'Graph It!' to see the chart."
    let nextButtonText = "Ok!"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        self.coachMarksController.dataSource = self
        
        self.coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)

        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Source: https://stackoverflow.com/questions/47754472/ios-uinavigationbar-button-remains-faded-after-segue-back/47839657#47839657
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.showGeoInstructions() {
            startInstructions()
            UserDefaults.setShowGeoInstructions(false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
    }
    
    func startInstructions() {
        self.coachMarksController.start(on: self)
    }
    
    private func setupUI() {
        
        tableView.dataSource = viewModel.geosDataSource
        
        self.instructionsLabel.text = "Choose the whole country and/or one or more states."
    }
    
    private func bindViewModel() {
        
        // Inputs
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] in self?.alert(title: $0, message: $1) })
            .disposed(by: disposeBag)
        
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.dataChanged
            .subscribe(onNext: { [weak self] in self?.tableView.reloadData()
                })
            .disposed(by: disposeBag)
        
        viewModel.querying
            .drive(onNext: { [weak self] querying in
                self?.graphItButton.isEnabled = !querying
                }
            )
            .disposed(by: disposeBag)
        
        graphItButton.rx.tap
           // .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.graphIt)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                if let cell = self.tableView.cellForRow(at: indexPath) as? StateCell {
                    cell.accessoryType = .checkmark
                }
                return self.viewModel.geoAtIndexPath(indexPath)
            }
            .bind(to: viewModel.selectGeo)
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeselected
            .map { [unowned self] indexPath in
                if let cell = self.tableView.cellForRow(at: indexPath) as? StateCell {
                    cell.accessoryType = .none
                }
                return self.viewModel.geoAtIndexPath(indexPath)
            }
            .bind(to: viewModel.deselectGeo)
            .disposed(by: disposeBag)
        
        selectAllButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.selectAll)
            .disposed(by: disposeBag)
        
        deselectAllButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.deselectAll)
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Protocol Conformance | CoachMarksControllerDataSource
extension GeosViewController: CoachMarksControllerDataSource {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        var coachMark : CoachMark
        
        switch(index) {
        case 0:
            coachMark = coachMarksController.helper.makeCoachMark(for: tableView)
            coachMark.allowTouchInsideCutoutPath = true
        case 1:
            let view = graphItButton.value(forKey: "view") as! UIView
            coachMark = coachMarksController.helper.makeCoachMark(for: view)
            coachMark.allowTouchInsideCutoutPath = true
        case 2:
            let view = self.tabBarController?.tabBar.items?[1].value(forKey: "view") as? UIView
            coachMark = coachMarksController.helper.makeCoachMark(for: view)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        
        return coachMark
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {

        var bodyView : CoachMarkBodyView
        var arrowView : CoachMarkArrowView?
        
        
        switch(index) {
        case 0:
            let coachMarkBodyView = CustomCoachMarkBodyView()
            var coachMarkArrowView: TransparentCoachMarkArrowView? = nil
            
            coachMarkBodyView.hintLabel.text = self.introText
            coachMarkBodyView.nextButton.setTitle(self.nextButtonText, for: UIControlState())
            
            if let arrowOrientation = coachMark.arrowOrientation {
                coachMarkArrowView = TransparentCoachMarkArrowView(orientation: arrowOrientation)
            }
            
            bodyView = coachMarkBodyView
            arrowView = coachMarkArrowView
        case 1:
            let coachMarkBodyView = CustomCoachMarkBodyView()
            var coachMarkArrowView: TransparentCoachMarkArrowView? = nil
            
            coachMarkBodyView.hintLabel.text = self.graphItText
            coachMarkBodyView.nextButton.setTitle(self.nextButtonText, for: UIControlState())
            
            if let arrowOrientation = coachMark.arrowOrientation {
                coachMarkArrowView = TransparentCoachMarkArrowView(orientation: arrowOrientation)
            }
            
            bodyView = coachMarkBodyView
            arrowView = coachMarkArrowView
            /*
             case 2:
             coachViews.bodyView.hintLabel.text = scatterChartText
             coachViews.bodyView.nextLabel.text = self.nextButtonText
             case 3:
             coachViews.bodyView.hintLabel.text = self.postsText
             coachViews.bodyView.nextLabel.text = self.nextButtonText
             case 4:
             coachViews.bodyView.hintLabel.text = self.reputationText
             coachViews.bodyView.nextLabel.text = self.nextButtonText
             */
        default:
            let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
            
            bodyView = coachViews.bodyView
            arrowView = coachViews.arrowView
        }
        
        return (bodyView: bodyView, arrowView: arrowView)
    }
}
