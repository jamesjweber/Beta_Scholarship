////
////  TimePerClassBarChart.swift
////  Beta_Scholarship
////
////  Created by James Weber on 3/12/18.
////  Copyright © 2018 James Weber. All rights reserved.
////
//
//import UIKit
//import Charts
//
//class TimePerClassBarChart: UIView {
//
//    // Bar chart properties
//    var barChartView = BarChartView()
//    var dataEntry: [BarChartDataEntry] = []
//
//    // Char data
//    var className = [String]()
//    var averageHoursStudied = [String]()
//
//    var delegate: GetChartData! {
//        didSet {
//            populateData()
//            barChartSetup()
//        }
//    }
//
//    func populateData() {
//        className = delegate.className
//        averageHoursStudied = delegate.averageHoursStudied
//    }
//
//    func barChartSetup() {
//        // Bar chart config
//        self.backgroundColor = UIColor.white
//        self.addSubview(barChartView)
//        barChartView.translatesAutoresizingMaskIntoConstraints = false
//        barChartView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
//        barChartView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        barChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        barChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//
//        // Bar chart animation
//        let duration = 1.0
//        barChartView.animate(xAxisDuration: duration, yAxisDuration: duration, easingOption: .easeInSine)
//
//        // Bar chart population
//        setBarChart(dataPoints: className, values: averageHoursStudied)
//    }
//
//    func setBarChart(dataPoints: [String], values: [String]) {
//
//        // No data setup
//        barChartView.noDataTextColor = UIColor.lightGray
//        barChartView.noDataText = "No data for the chart"
//        barChartView.backgroundColor = UIColor.white
//
//        // Data point setup & color config
//        for i in 0..<dataPoints.count {
//            let dataPoint = BarChartDataEntry(x: Double(i), y: Double(values[i])!)
//            dataEntry.append(dataPoint)
//        }
//
//        let chartDataSet = BarChartDataSet(values: dataEntry, label: "% of hours studied")
//        let chartData = BarChartData()
//        chartData.addDataSet(chartDataSet)
//        chartData.setDrawValues(false) // true if we want values above bar
//        chartDataSet.colors = [Colors().color(named: "blue")]
//
//        // Axes setup
//        let formatter: ChartFormatter = ChartFormatter()
//        formatter.setValues(values: dataPoints)
//        let xaxis:XAxis = XAxis()
//        xaxis.valueFormatter = formatter
//
//        barChartView.xAxis.labelPosition = .bottom
//        barChartView.xAxis.drawGridLinesEnabled = false // true if you want X-Axis grid lines
//        barChartView.xAxis.valueFormatter = xaxis.valueFormatter
//        barChartView.xAxis.labelCount = values.count
//        barChartView.chartDescription?.enabled = false
//        barChartView.legend.enabled = false
//        barChartView.rightAxis.enabled = false
//        barChartView.leftAxis.drawAxisLineEnabled = false
//        barChartView.leftAxis.drawGridLinesEnabled = true  // true if you want Y-Axis grid lines
//        barChartView.leftAxis.drawLabelsEnabled = true
//        //barChartView
//        barChartView.data = chartData
//    }
//}
