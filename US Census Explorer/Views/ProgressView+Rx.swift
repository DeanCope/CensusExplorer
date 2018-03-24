//
//  ProgressView+Rx.swift
//  CensusAPI
//
//  Created by Dean Copeland on 2/1/18.
//  Copyright © 2018 Dean Copeland. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: ProgressView {
    
    var animate: Binder<Bool> {
        return Binder(self.base) { progressView, animate in
            progressView.animate = animate
        }
    }
    
    var progress: Binder<Float> {
        return Binder(self.base) { progressView, progress in
            let progress = max(0, min(progress, 1))
            progressView.progress = progress
        }
    }
    
    var labelText: Binder<String?> {
        return Binder(self.base) { progressView, labelText in
            progressView.labelText = labelText ?? ""
        }
    }
}
