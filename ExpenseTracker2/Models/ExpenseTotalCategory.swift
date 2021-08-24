//
//  ExpenseTotalManager.swift
//  ExpenseTracker2
//
//  Created by curry敏 on 2021/8/15.
//

import Foundation

struct ExpenseTotalCategory {    
    
    let category: String
    let number: Int
    var totalCategory: [String : Any] {
        return ["category": self.category, "total": self.number]
    }
    
}
