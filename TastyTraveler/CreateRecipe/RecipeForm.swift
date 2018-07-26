//
//  RecipeForm.swift
//  TastyTraveler
//
//  Created by Michael Bart on 7/11/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Eureka

class RecipeForm: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        
        form +++
            MultivaluedSection(multivaluedOptions: [.Insert], header: "", footer: "") {
                $0.addButtonProvider = { section in
                    return ButtonRow() {
                        $0.title = "Add new ingredient"
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .left
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return TextAreaRow() {
                        $0.placeholder = "Enter ingredient"
                        $0.textAreaHeight = .dynamic(initialTextViewHeight: 20)
                    }
                }
                $0 <<< TextAreaRow() {
                    $0.placeholder = "Enter ingredient"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 20)
                }
            }
    }
}
