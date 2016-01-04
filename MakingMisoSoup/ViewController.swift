//
//  ViewController.swift
//  MakingMisoSoup
//
//  Created by shoji on 2016/01/04.
//  Copyright © 2016年 com.shoji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var misoSoupMaker: MisoSoupMaker!

    override func viewDidLoad() {
        super.viewDidLoad()

        misoSoupMaker = MisoSoupMaker()
    }
}
