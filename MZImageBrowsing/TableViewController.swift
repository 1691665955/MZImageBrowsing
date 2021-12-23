//
//  TableViewController.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/23.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? images.count : urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell
        if cell == nil {
            cell = TableViewCell.init(style: .default, reuseIdentifier: "TableViewCell")
        }
        if indexPath.section == 0 {
            cell?.setImages(images: images[indexPath.row])
        } else {
            cell?.setUrl(urls: urls[indexPath.row])
        }
        cell?.preview = {index, imageView in
            if indexPath.section == 0 {
                var imageViews: [UIImageView] = []
                for i in 0..<self.images.count {
                    let newIndexPath = IndexPath(row: i, section: 0)
                    if let cell = self.tableView.cellForRow(at: newIndexPath) as? TableViewCell {
                        imageViews.append(cell.iconView1)
                        imageViews.append(cell.iconView2)
                    }
                }
                let controller = MZImageBrowsingController(imageViewList: imageViews, currentIndex: indexPath.row * 2 + index)
                self.present(controller, animated: true, completion: nil)
            } else {
                var urls: [String] = []
                for strings in self.urls {
                    for url in strings {
                        urls.append(url)
                    }
                }
                let controller = MZImageBrowsingController(imageUrlList: urls, currentImageView: imageView, currentIndex: indexPath.row * 2 + index)
                self.present(controller, animated: true, completion: nil)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_WIDHT / 2 + 10
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Images" : "Urls"
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.classForCoder(), forCellReuseIdentifier: "TableViewCell")
        return tableView
    }()
    
    let images:[[UIImage]] = [[UIImage(named: "111")!, UIImage(named: "222")!], [UIImage(named: "333")!, UIImage(named: "555")!]]
    let urls: [[String]] = [["https://n.sinaimg.cn/sinacn18/352/w640h512/20180810/60c9-hhnunsq9508736.jpg",
                             "https://5b0988e595225.cdn.sohucs.com/q_70,c_zoom,w_640/images/20180702/b90656aeceec4dd5b45de1f0a3f605c3.jpeg"],
                            ["https://b-ssl.duitang.com/uploads/item/201501/30/20150130203141_mXWze.thumb.700_0.jpeg",
                             "https://b-ssl.duitang.com/uploads/item/201207/28/20120728104206_c5JEu.thumb.700_0.jpeg"],
                            ["https://b-ssl.duitang.com/uploads/item/201703/30/20170330200900_UMCLz.jpeg",
                             "https://i0.hdslb.com/bfs/article/7406a34172fd9c73651235ded78ea10147eb23ce.jpg"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MZImageBrowsing-TableView"
        self.view.addSubview(tableView)
        self.tableView.frame = self.view.bounds
    }
    
}
