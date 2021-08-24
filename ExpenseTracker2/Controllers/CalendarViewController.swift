//
//  CalenderViewController.swift
//  ExpenseTracker2
//
//  Created by curry敏 on 2021/8/10.
//

import UIKit
import FSCalendar
import Firebase

class CalendarViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var spendLabel: UILabel!
    @IBOutlet weak var calenderView: FSCalendar!
    @IBOutlet weak var refreshButton: UIButton!
    
    let formatter = DateFormatter()
    var expenseData = [ExpenseSpend]()
    let db = Firestore.firestore()
    let now = Date()
    var passIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calenderView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        refreshButton.layer.cornerRadius = refreshButton.layer.frame.height / 2
        refreshButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        tableView.register(UINib.init(nibName: ExpenseConstant.nibCell, bundle: nil), forCellReuseIdentifier: ExpenseConstant.cellidentifier)
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let today = formatter.string(from: now)
        dateLabel.text = String(today)
        loadDate(date: today)
    }
    
    func loadDate(date: String) {
        var total: Int = 0
        passIn = false
        db.collection(ExpenseConstant.collection)
            .whereField(ExpenseConstant.date, isEqualTo: date)
            .addSnapshotListener { querysnapshot, error in
                print("searching for data")
                self.expenseData = []
                if let e = error {
                    print("Error retrieving data from firestore. \(e)")
                } else {
                    if let query = querysnapshot?.documents {
                        for doc in query {
                            let data = doc.data()
                            if let expense = data[ExpenseConstant.expense] as? String, let category = data[ExpenseConstant.category] as? String, let note = data[ExpenseConstant.note] as? String, let timestamp = data[ExpenseConstant.date] as? String
                            {
                                self.passIn = true
                                print("phase 2")
                                let newData = ExpenseSpend(expense: expense, category: category, date: timestamp, note: note)
                                self.expenseData.append(newData)
                                if let intN = Int(expense){
                                    total = total + intN
                                }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    self.spendLabel.text = String(total)
                                    print("total: \(total)")
                                    print("expenseData: \(self.expenseData)")
                                }
                            } else {
                                print("Error saving data from firestore to local")
                            }
                        }
                    }
                }
            }
        if passIn == false {
            print("There is no data in this date")
            expenseData.removeAll()
            total = 0
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.spendLabel.text = String(total)
                print("total:\(total)")
            }
        }
    }
    
    @IBAction func refreshToday(_ sender: UIButton) {
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        loadDate(date: formatter.string(from: now))
    }
    
}

extension CalendarViewController: FSCalendarDelegate {
     
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateTime = formatter.string(from: date)
        dateLabel.text = String(dateTime)
        print("selected: \(dateTime)")
        loadDate(date: dateTime)
    }
    
}


extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return expenseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let expenseData = expenseData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseConstant.cellidentifier, for: indexPath) as! ExpenseTableViewCell
        cell.cellimage.image = UIImage(named: expenseData.category)
        cell.cellExpense.text = expenseData.expense
        cell.noteLabel.text = expenseData.note
        return cell
    }
    
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
