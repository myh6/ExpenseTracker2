//
//  ChartViewController.swift
//  ExpenseTracker2
//
//  Created by curry敏 on 2021/8/10.
//

import UIKit
import Charts
import Firebase

class ChartViewController: UIViewController {

    @IBOutlet weak var refreshButton: ButtonModel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    let db = Firestore.firestore()
    var expenseCatData = [ExpenseTotalCategory]()
    var totalData: [ExpenseTotal] = []
    let date = Date()
    let formatter = DateFormatter()
    var datecomponent = DateComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        var last7days = [String]()
        for i in -6...0 {
            datecomponent.day = i
            let day = Calendar.current.date(byAdding: datecomponent, to: date)!
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            let stringDate = formatter.string(from: day)
            last7days.append(stringDate)
        }
        print("Last 7 days: \(last7days)")
        loadData(in: last7days)
        print("TotalData: \(totalData)")
    }
    
    func loadData(in days: [String]) {
        let myGroup = DispatchGroup()
        totalData = []
        for day in days {
            var total: Int = 0
            myGroup.enter()
            db.collection(ExpenseConstant.collection)
                .whereField(ExpenseConstant.date, isEqualTo: day)
                .getDocuments { querysnapshot, error in
                    if let e = error {
                        print("Error retrieving data from firebase. \(e)")
                    } else {
                        if let query = querysnapshot?.documents {
                            for doc in query {
                                let data = doc.data()
                                if let expense = data[ExpenseConstant.expense] as? String, let category = data[ExpenseConstant.category] as? String {
                                    if let intN = Int(expense) {
                                        let newCatDat = ExpenseTotalCategory(category: category, number: intN)
                                        self.expenseCatData.append(newCatDat)
                                        total = total + intN
                                    } else {
                                        print("Error converting string to Int")
                                        myGroup.leave()
                                    }
                                } else {
                                    print("Error converting Any to String?")
                                    myGroup.leave()
                                }
                            }
                            let newData = ExpenseTotal(date: day, number: total)
                            self.totalData.append(newData)
                            print("now the data is \(self.totalData)")
                            myGroup.leave()
                        }
                    }
                }
        }
        myGroup.notify(queue: .main) {
            print("Finish all request")
            print("Final data: \(self.totalData.count)")
            self.updateLineGraph(total: self.totalData)
            self.updatePieChart(total: self.expenseCatData)
        }
    }
    
    func updateLineGraph(total: [ExpenseTotal]) {
        var lineChartEntry = [ChartDataEntry]()
        let sortedDict = totalData.sorted(by: { $0.date < $1.date })
        print("After sorted: \(totalData)")
        for i in 0 ..< totalData.count {
            let value = ChartDataEntry(x: Double(i+1), y: Double(sortedDict[i].number))
            lineChartEntry.append(value)
            print(value)
        }
        print(lineChartEntry)
        let line = LineChartDataSet(entries: lineChartEntry)
        line.colors = [NSUIColor.init(displayP3Red: 121/255, green: 82/255, blue: 179/255, alpha: 1)]
        line.setCircleColor(NSUIColor.init(displayP3Red: 121/255, green: 82/255, blue: 179/255, alpha: 1))
        line.circleHoleColor = UIColor.white
        line.circleRadius = 1.0
        
        let gradientColors = [UIColor.init(displayP3Red: 121/255, green: 82/255, blue: 179/255, alpha: 1).cgColor, UIColor.clear.cgColor] as CFArray
        let colorLocation: [CGFloat] = [1.0, 0.0]
        guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocation) else {
            print("gradient eroor")
            return
        }
        line.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        line.drawFilledEnabled = true
        
        //lineChart.xAxis.labelPosition = .bottom
        lineChartView.xAxis.enabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        
        let data = LineChartData()
        data.addDataSet(line)
        //data.setDrawValues(false)
        
        DispatchQueue.main.async {
            print("Graph should change by now!!!")
            //self.lineChart.backgroundColor = UIColor.white
            self.lineChartView.data = data
        }
    }
    
    func updatePieChart(total: [ExpenseTotalCategory]) {
        
        print("piechartdata original: \(total)")
        var foodTotal: Int = 0
        var educationTotal: Int = 0
        var entertainmentTotal: Int = 0
        var pharmacyTotal: Int = 0
        var homeTotal: Int = 0
        var commuteTotal: Int = 0
        var moreTotal: Int = 0
        var shoppingTotal: Int = 0
        for data in total {
            switch data.category {
            case ExpenseConstant.food:
                foodTotal += data.number
            case ExpenseConstant.education:
                educationTotal += data.number
            case ExpenseConstant.entertainment:
                entertainmentTotal += data.number
            case ExpenseConstant.pharmacy:
                pharmacyTotal += data.number
            case ExpenseConstant.commute:
                commuteTotal += data.number
            case ExpenseConstant.home:
                homeTotal += data.number
            case ExpenseConstant.shopping:
                shoppingTotal += data.number
            case ExpenseConstant.more:
                moreTotal += data.number
            default:
                print("Error recognizing data category")
            }
        }
        //Entry
        let pieChartEntry: [PieChartDataEntry] = [
            PieChartDataEntry(value: Double(foodTotal), label: ExpenseConstant.food),
            PieChartDataEntry(value: Double(shoppingTotal), label: ExpenseConstant.shopping),
            PieChartDataEntry(value: Double(educationTotal), label: ExpenseConstant.education),
            PieChartDataEntry(value: Double(entertainmentTotal), label: ExpenseConstant.entertainment),
            PieChartDataEntry(value: Double(homeTotal), label: ExpenseConstant.home),
            PieChartDataEntry(value: Double(commuteTotal), label: ExpenseConstant.commute),
            PieChartDataEntry(value: Double(pharmacyTotal), label: ExpenseConstant.pharmacy),
            PieChartDataEntry(value: Double(moreTotal), label: ExpenseConstant.more)
        ]
        //Dataset
        let set = PieChartDataSet(entries: pieChartEntry)
        set.colors = [Color.foodColor, Color.shoppingColor, Color.educationColor, Color.entertainmentColor, Color.homeColor, Color.homeColor, Color.commuteColor, Color.pharmacyColor, Color.moreColor]
        set.selectionShift = 5
        set.sliceSpace = 3
        //set.drawValuesEnabled = false
        
        //Data
        let data = PieChartData(dataSet: set)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        pieChartView.data = data
        pieChartView.usePercentValuesEnabled = true
        let legend = pieChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
    }
    
    @IBAction func refreshPresed(_ sender: UIButton) {
        var last7days = [String]()
        for i in -6...0 {
            datecomponent.day = i
            let day = Calendar.current.date(byAdding: datecomponent, to: date)!
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            let stringDate = formatter.string(from: day)
            last7days.append(stringDate)
        }
        loadData(in: last7days)
    }
    
}
