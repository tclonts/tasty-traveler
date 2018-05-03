//
//  SectionHeaderView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/3/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class SectionHeaderView: UICollectionViewCell {
    
    let sectionLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let numberOfRecipesLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
       
    }
}
