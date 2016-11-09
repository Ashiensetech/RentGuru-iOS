//
//  ExpandableCategory.swift
//  RentGuru
//
//  Created by Workspace Infotech on 11/8/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//

import UIKit

class ExpandableCategory: NSObject {
    var category: Category!
    var isTopLevelCategory: Bool = false
    var isVisible: Bool = false
    var isExpanded: Bool = false
    var isLastChild: Bool = false
    var parentCategory: ExpandableCategory? = nil
    var level: Int = 0
    var isSelected = false
    
    init(category: Category, isTopLevelCategory: Bool, isVisible: Bool, isExpanded: Bool, isLastChild: Bool, parentCategory: ExpandableCategory?, level: Int, isSelected: Bool) {
        self.category = category
        self.isTopLevelCategory = isTopLevelCategory
        self.isVisible = isVisible
        self.isExpanded = isExpanded
        self.isLastChild = isLastChild
        self.parentCategory = parentCategory
        self.level = level
        self.isSelected = isSelected
    }
}
