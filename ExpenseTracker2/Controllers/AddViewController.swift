//
//  AddViewController.swift
//  ExpenseTracker2
//
//  Created by curry敏 on 2021/8/4.
//

import UIKit
import Firebase

class AddViewController: UIViewController {

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var calPopView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateSet: UIDatePicker!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var categoryButton: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var totalSpent: UILabel!
    
    private var isFinishedTyping: Bool = true
    private var calculator = CalculatorLogic()
    private var displayValue: Double {
        get {
            guard let number = Double(displayLabel.text!) else {
                fatalError("Cannot convert label to digit")
            }
            return number
        } set {
            displayLabel.text = String(newValue)
        }
    }

    private var chooseCategory: String?
    private let db = Firestore.firestore()
    private let formatter = DateFormatter()
    var expenseData = [ExpenseSpend]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let now = Date()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateTime = formatter.string(from: now)
        
        addButton.layer.shadowColor = UIColor.systemGray.cgColor
        addButton.layer.shadowRadius = 3
        addButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        addButton.layer.shadowOpacity = 1
        blurView.bounds = self.view.bounds
        calPopView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.9, height: self.view.bounds.height * 0.8 )
        
        noteTextField.attributedPlaceholder = NSAttributedString(string: "Note(Optional)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: ExpenseConstant.nibCell, bundle: nil), forCellReuseIdentifier: ExpenseConstant.cellidentifier)
        loadData(dateTime)
        print("expenseData in viewDidLoad: \(expenseData)")
    }
    
    //MARK: - calculator
    @IBAction func addButtonPressed(_ sender: UIButton) {
        animateScaleIn(desiredView: blurView)
        animateScaleIn(desiredView: calPopView)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        animateScaleOut(desiredView: blurView)
        animateScaleOut(desiredView: calPopView)
        displayLabel.text = "0"
    }
    
    @IBAction func calcButtonPressed(_ sender: UIButton) {
        
        isFinishedTyping = true
        if let calcuMethod = sender.currentTitle {
            calculator.setNumber(displayValue)
            guard let result = calculator.calculate(symbol: calcuMethod) else {
                fatalError("The result of the calculation is nil.")
            }
            displayValue = result
        }
    }
    
    @IBAction func numBottonPressed(_ sender: UIButton) {
        //What should happen when a number is entered into the keypad
        if let numValue = sender.currentTitle {
            
            if isFinishedTyping {
                displayLabel.text = numValue
                isFinishedTyping = false
            } else {
                if numValue == "." {
                    
                    guard let currentDisplayValue = Double(displayLabel.text!) else {
                        fatalError("Cannot convert display label text to a Double!")
                    }
                    let isInt = floor(currentDisplayValue) == currentDisplayValue
                    if !isInt {
                        return
                    }
                }
                displayLabel.text = displayLabel.text! + numValue
            }
        }
        
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        for button in categoryButton {
            button.tintColor = Color.purple
            button.backgroundColor = Color.lightPurple
        }
        sender.tintColor = Color.lightPurple
        sender.backgroundColor = Color.purple
        chooseCategory = sender.currentTitle!
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let sendDate = formatter.string(from: dateSet.date)
        if let expenseBody = displayLabel.text, let category = chooseCategory, let note = noteTextField.text {
            db.collection(ExpenseConstant.collection).addDocument(data: [
                ExpenseConstant.expense: expenseBody,
                ExpenseConstant.category: category,
                ExpenseConstant.date: sendDate,
                ExpenseConstant.note: note
            ]) { error in
                if let e = error {
                    print("error saving data to firebase. \(e)")
                } else {
                    print("data sent successfully.")
                }
            }
        }
        animateScaleOut(desiredView: calPopView)
        animateScaleOut(desiredView: blurView)
        displayLabel.text = "0"
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //Animates a view to scale in and display
    func animateScaleIn(desiredView: UIView) {
        let backgroundView = self.view!
        backgroundView.addSubview(desiredView)
        desiredView.center = backgroundView.center
        desiredView.isHidden = false
        desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        desiredView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
        }
    }
    
    //Animates a view to scale out remove from the display
    func animateScaleOut(desiredView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            desiredView.alpha = 0
        }, completion: { (success: Bool) in
            desiredView.removeFromSuperview()
        })
        UIView.animate(withDuration: 0.2, animations: {
        }, completion: { _ in
            
        })
    }
    
    func loadData(_ dateTime: String) {
        print("Loading data...")
        db.collection(ExpenseConstant.collection)
            .whereField(ExpenseConstant.date, isEqualTo: dateTime)
            .addSnapshotListener { querySnapshot, error in
                self.expenseData = []
                var total: Int = 0
                if let e = error {
                    print("There was an isssue retrieving data from Firestore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let expense = data[ExpenseConstant.expense] as? String, let category = data[ExpenseConstant.category] as? String, let note = data[ExpenseConstant.note] as? String, let timestamp = data[ExpenseConstant.date] as? String
                                {
                                let newData = ExpenseSpend(expense: expense, category: category, date: timestamp, note: note)
                                self.expenseData.append(newData)
                                if let intN = Int(expense) {
                                    total = total + intN
                                }
                                DispatchQueue.main.async {
                                    self.totalSpent.text = String(total)
                                    self.tableView.reloadData()
                                }
                            } else {
                                print("Pass unsuccessfully in loadData()")
                            }
                        }
                    }
                }
            }
    }

}

extension AddViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row > expenseData.count - 1) {
            return UITableViewCell()
        } else {
            let expenseData = expenseData[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseConstant.cellidentifier, for: indexPath) as! ExpenseTableViewCell
            cell.cellimage.image = UIImage(named: expenseData.category)
            cell.cellExpense.text = expenseData.expense
            cell.noteLabel.text = expenseData.note
            return cell
        }
    }
    
}

extension AddViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
