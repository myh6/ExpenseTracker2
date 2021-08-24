//
//  ExpenseTotal.swift
//  ExpenseTracker2
//
//  Created by curry敏 on 2021/8/14.
//

import Foundation


struct ExpenseTotal {
   
    let date: String
    let number: Int
    var total: [String : Any] {
        return ["date": date, "number": number]
    }

    
}
