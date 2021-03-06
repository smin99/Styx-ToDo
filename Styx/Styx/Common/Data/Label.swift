//
//  Label.swift
//  Styx
//
//  Created by HwangSeungmin on 12/14/18.
//  Copyright © 2018 Min. All rights reserved.
//

import Foundation

// Top Data Structure
class Label {
    var ID: Int64
    var Title: String
    var ColorID: Int    // 0 if no color
    
    var taskList: Array<Task>!
    
    init(ID: Int64 = 0, Title: String = "", ColorID: Int = 0) {
        self.ID = ID
        self.Title = Title
        self.ColorID = ColorID
        
        taskList = Array<Task>()
    }
}
