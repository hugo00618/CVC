//
//  MySplitVC.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-27.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class MySplitVC: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }
}
