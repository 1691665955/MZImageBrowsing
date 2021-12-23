//
//  ViewController.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/22.
//

import UIKit

let SCREEN_WIDHT = UIScreen.main.bounds.size.width

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MZImageBrowsing"
    }

    @IBAction func toTableView(_ sender: Any) {
        self.navigationController?.pushViewController(TableViewController(), animated: true)
    }
    
    @IBAction func toCollectionView(_ sender: Any) {
        self.navigationController?.pushViewController(CollectionViewController(), animated: true)
    }
}

