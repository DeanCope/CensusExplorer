//
//  UserDefaults.swift
//  CensusAPI
//
//  Created by Dean Copeland on 10/7/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import Charts

// MARK: UserDefaults

extension UserDefaults {
    
    private struct Keys {
       // static let HasLaunchedBefore = "HasLaunchedBefore"
        static let ChartLineWidth = "ChartLineWidth"
        static let ChartShowValues = "ChartShowValues"
        //static let ChartCubicSmoothing = "ChartCubicSmoothing"
        static let LineChartMode = "LineChartMode"  // based on LineChartDataSet.Mode
    }
    
    static func removeCensusObjects() {
        UserDefaults.standard.removeObject(forKey: Keys.ChartLineWidth)
        UserDefaults.standard.removeObject(forKey: Keys.ChartShowValues)
        UserDefaults.standard.removeObject(forKey: Keys.LineChartMode)
    }
    
    // Check if UserDefaults.standard already contains the key.
    // This is to distinguish between the case where the user has made no choice vs the case
    // where they chose the value that UserDefaults returns by default.
    // For example, if the user explicitly chose false for a boolean value
    private static func containsKey(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    static func chartLineWidth() -> Float {
        let storedValue = UserDefaults.standard.float(forKey: Keys.ChartLineWidth)
        return storedValue != 0 ? storedValue : 2.0
    }
    
    static func setChartLineWidth(_ width: Float) {
        UserDefaults.standard.set(width, forKey: Keys.ChartLineWidth)
    }
    
    static func chartShowValues() -> Bool {
        if UserDefaults.containsKey(Keys.ChartShowValues) {
            return UserDefaults.standard.bool(forKey: Keys.ChartShowValues)
        } else {
            return false    // Default to not show values
        }
    }
    
    static func setChartShowValues(_ newValue: Bool) {
        UserDefaults.standard.set(newValue, forKey: Keys.ChartShowValues)
    }
    
    static func lineChartMode() -> LineChartDataSet.Mode {
        if UserDefaults.containsKey(Keys.LineChartMode) {
            let storedValue = UserDefaults.standard.integer(forKey: Keys.LineChartMode)
            return LineChartDataSet.Mode(rawValue: storedValue) ?? LineChartDataSet.Mode.linear
        } else {
            return LineChartDataSet.Mode.linear
        }
    }
    
    static func setLineChartMode(_ mode: LineChartDataSet.Mode) {
        UserDefaults.standard.set(mode.rawValue, forKey: Keys.LineChartMode)
    }
    
    static func chartBackgroundColor() -> UIColor {
        return UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
    }
    
    static var defaultYear: Int16 {
        get {
            return 2015
        }
    }
    
    static var defaultYearString: String {
        get {
            return "2015"
        }
    }
    
}








