//
// Created by James Weber on 3/12/18.
// Copyright (c) 2018 James Weber. All rights reserved.
//

import UIKit
import Charts

protocol GetChartData {
    func getChartData(with dataPoints: [String], values: [String])
    var className: [String] { get set }
    var averageHoursStudied: [String] { get set }
}

class ChartViewController: UIViewController, GetChartData {

    // Chart data
    var className = [String]()
    var averageHoursStudied = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate chart data
        populateChartData()

        // Bar chart
        barChart()
    }

    // Populate
    func populateChartData() {
        className = ["ECE 302", "ECE 337", "ECE 364", "ECE 368", "MA 265"]
        averageHoursStudied = ["15","35","20","20","10","25"]
        self.getChartData(with: className, values: averageHoursStudied)
    }

    // Chart options
    func barChart() {
        let barChart = TimePerClassBarChart(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height))
        barChart.delegate = self
        self.view.addSubview(barChart)
    }
    
    // Conform to protocol
    func getChartData(with dataPoints: [String], values: [String]) {
        self.className = dataPoints
        self.averageHoursStudied = values
    }
}

public class ChartFormatter: NSObject, IAxisValueFormatter {

    var className = [String]()

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return className[Int(value)]
    }

    public func setValues(values: [String]) {
        self.className = values
    }
}
