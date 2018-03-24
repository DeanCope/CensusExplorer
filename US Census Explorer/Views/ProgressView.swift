//
//  ProgressView.swift
//  CensusAPI
//
//  Created by Dean Copeland on 2/1/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import UIKit

@IBDesignable class ProgressView: UIView {

    //MARK: Properties
    lazy var stack:UIStackView = {
        let s = UIStackView(frame: self.bounds)
        s.axis = .vertical
        s.distribution = .fillProportionally
        s.alignment = .center
        s.spacing = 5
        s.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(s)
        return s
    }()
    private var barView = UIProgressView()
    private var labelView = UILabel()
    private var activityView = UIActivityIndicatorView()
    
    public var progress = Float(0.0) {
        didSet {
            updateBarView()
        }
    }
    public var labelText = "" {
        didSet {
            updateLabelView()
        }
    }
    public var animate = Bool(false) {
        didSet {
            updateActivityView()
        }
    }
    
    @IBInspectable var activityViewSize: CGSize = CGSize(width: 50.0, height: 50.0) {
        didSet {
            setupUI()
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    //MARK: Priate Methods
    
    private func setupUI() {
        layer.borderWidth = 3
        layer.cornerRadius = 20
        layer.borderColor = UIColor.blue.cgColor
        
        stack.removeArrangedSubview(activityView)
        activityView.removeFromSuperview()
        activityView.color = UIColor.black
        activityView.startAnimating()
     //   activityView.translatesAutoresizingMaskIntoConstraints = false
     //   activityView.heightAnchor.constraint(equalToConstant: activityViewSize.height).isActive = true
      //  activityView.widthAnchor.constraint(equalToConstant: activityViewSize.width).isActive = true
        stack.addArrangedSubview(activityView)
        updateActivityView()
        
        stack.removeArrangedSubview(labelView)
        labelView.removeFromSuperview()
        //labelView.backgroundColor = UIColor.red
        labelView.text = labelText
     //   labelView.translatesAutoresizingMaskIntoConstraints = false
     //   labelView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
    //    labelView.widthAnchor.constraint(equalToConstant: 84.0).isActive = true
        //constraint(equalToConstant: 10).isActive = true
        stack.addArrangedSubview(labelView)
        updateLabelView()
        
        // Progress bar
        stack.removeArrangedSubview(barView)
        barView.removeFromSuperview()
        //barView.backgroundColor = UIColor.red
     //   barView.translatesAutoresizingMaskIntoConstraints = false
     //   barView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        barView.layer.borderWidth = 2
        barView.layer.borderColor = UIColor.blue.cgColor
        barView.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        
        // Add the progress bar to the stack
        stack.addArrangedSubview(barView)
        updateBarView()
        
    }
    
    private func updateBarView() {
        // Do not animate resetting back to 0 progress
        let animated = progress > 0.0
        barView.setProgress(progress, animated: animated)
    }
    
    private func updateLabelView() {
        labelView.text = labelText
    }
    
    private func updateActivityView() {
        if animate {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
    }
    
    
}
