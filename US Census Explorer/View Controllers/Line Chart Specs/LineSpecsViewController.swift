//
//  LineSpecsViewController.swift
//  CensusAPI
//
//  Created by Dean Copeland on 8/29/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Instructions

// This class is responsible for displaying the first (functional) view that the user sees.
// It displays a list of census topics for the user to choose from.
// If the census data has not yet been retrieved, the CensusDataSource is used
// to get the data from the Census server.
// The user also has the option to refresh the census data.

class LineSpecsViewController: UIViewController, StoryboardInitializable {
    
    var viewModel: LineSpecsViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reloadDataButton: UIButton!
    @IBOutlet weak var progressView: ProgressView!
    
    var coachMarksController = CoachMarksController()
    let introText = "Welcome to US Census Explorer. This app will let you graph various facts from the US Census as either a line chart or a scatter chart.  We are currently on the Line Chart tab, which lets you select a single census topic and create a line chart for one or more geographies to see how the vales change over time."
    let chooseATopicText = "Touch a topic to explore as a Line Graph"
    let scatterChartText = "The Scatter Chart tab lets you choose two topics so you can see how they compare for various geographies."
    let nextButtonText = "Ok!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        //self.coachMarksController.overlay.allowTap = true
        self.coachMarksController.dataSource = self
        
        self.coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip Tutorial", for: .normal)
        skipView.setTitleColor(UIColor.white, for: .normal)
        skipView.setBackgroundImage(nil, for: .normal)
        skipView.setBackgroundImage(nil, for: .highlighted)
        skipView.layer.cornerRadius = 0
        skipView.backgroundColor = UIColor.darkGray
        
        self.coachMarksController.skipView = skipView
        
        bindViewModel()
    }
    
    private func setupUI() {
        
        tableView.dataSource = viewModel.factsDataSource
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.Identifier) as! HeaderTableViewCell
        headerCell.sectionName = viewModel.headerCellSectionName
        tableView.tableHeaderView = headerCell
    }
    
    private func bindViewModel() {
        
        // Inputs from ViewModel to UI
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] title, message in self?.alert(title: title, message: message) })
            .disposed(by: rx.disposeBag)
        
        viewModel.querying
            .drive(onNext: { [weak self] querying in
                self?.progressView.isHidden = !querying
                self?.reloadDataButton.isEnabled = !querying
                self?.tableView.allowsSelection = !querying
                }
            )
            .disposed(by: rx.disposeBag)
        
        viewModel.querying
            .drive(progressView.rx.animate)
            .disposed(by: rx.disposeBag)

         viewModel.queryProgress
            .drive(progressView.rx.progress)
            .disposed(by: rx.disposeBag)
        
        viewModel.progressMessage
            .drive(progressView.rx.labelText)
            .disposed(by: rx.disposeBag)

        viewModel.queryCompletion
            .drive (onNext: {[weak self] success, message, reload in
                guard !success || reload else { return }
                guard let message = message else { return }
                let title = success ? "Success" : "Error"
                self?.alert(title: title, message: message)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.dataUpdated
            .drive(onNext: { [weak self] updated in
                self?.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        
        // Outputs from UI to ViewModel
        reloadDataButton.rx.tap
            .bind(to: viewModel.requestReloadData)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .map { [unowned self] indexPath in
                return self.viewModel.factAtIndexPath(indexPath)
            }
            .bind(to: viewModel.selectFact)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemAccessoryButtonTapped
            .map { [unowned self] indexPath in
                return self.viewModel.factAtIndexPath(indexPath)
            }
            .bind(to: viewModel.requestFactDetails)
            .disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshGeosAndValues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.showLineChartInstructions() {
            startInstructions()
            UserDefaults.setShowLineChartInstruction(false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
    }
    
    func startInstructions() {
        self.coachMarksController.start(on: self)
    }
}

// MARK: - Extension - UITableViewDelegate
extension LineSpecsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 27
    }
}

// MARK: - Protocol Conformance | CoachMarksControllerDataSource
extension LineSpecsViewController: CoachMarksControllerDataSource {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        
        // This will create cutout path matching perfectly the given view.
        // No padding!
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        
        var coachMark : CoachMark
        
        switch(index) {
        case 0:
            let view = self.tabBarController?.tabBar.items?[0].value(forKey: "view") as? UIView
            coachMark = coachMarksController.helper.makeCoachMark(for: view)
        case 1:
            let poi = tableView.center
            coachMark = coachMarksController.helper.makeCoachMark(for: tableView, pointOfInterest: poi, cutoutPathMaker: flatCutoutPathMaker)
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
            
            coachMarkBodyView.hintLabel.text = self.chooseATopicText
            coachMarkBodyView.nextButton.setTitle(self.nextButtonText, for: UIControlState())
            
            if let arrowOrientation = coachMark.arrowOrientation {
                coachMarkArrowView = TransparentCoachMarkArrowView(orientation: arrowOrientation)
            }
            
            bodyView = coachMarkBodyView
            arrowView = coachMarkArrowView

        default:
            let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
            
            bodyView = coachViews.bodyView
            arrowView = coachViews.arrowView
        }
        
        return (bodyView: bodyView, arrowView: arrowView)
    }
}



