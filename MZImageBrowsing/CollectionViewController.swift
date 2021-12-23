//
//  CollectionViewController.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/23.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? images.count : urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        if indexPath.section == 0 {
            cell.setImage(image: images[indexPath.row])
        } else {
            cell.setUrl(url: urls[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            var imageViews: [UIImageView] = []
            for i in 0..<images.count {
                let newIndexPath = IndexPath(item: i, section: 0)
                if let cell = collectionView.cellForItem(at: newIndexPath) as? CollectionViewCell {
                    imageViews.append(cell.imageView)
                }
            }
            let imageBrowsing = MZImageBrowsingController.init(imageViewList: imageViews, currentIndex: indexPath.row)
            self.present(imageBrowsing, animated: true, completion: nil)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            let imageBrowsing = MZImageBrowsingController.init(imageUrlList: self.urls, currentImageView: cell.imageView, currentIndex: indexPath.row)
            self.present(imageBrowsing, animated: true, completion: nil)
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: SCREEN_WIDHT / 2 - 30, height: SCREEN_WIDHT / 2 - 30)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 202, right: 20)
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 18
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "CollectionViewCell")
        return collectionView
    }()
    
    let images: [UIImage] = [UIImage(named: "111")!, UIImage(named: "222")!, UIImage(named: "333")!, UIImage(named: "444")!, UIImage(named: "555")!]
    
    let urls = ["https://n.sinaimg.cn/sinacn18/352/w640h512/20180810/60c9-hhnunsq9508736.jpg",
                "https://5b0988e595225.cdn.sohucs.com/q_70,c_zoom,w_640/images/20180702/b90656aeceec4dd5b45de1f0a3f605c3.jpeg",
                "https://b-ssl.duitang.com/uploads/item/201501/30/20150130203141_mXWze.thumb.700_0.jpeg",
                "https://b-ssl.duitang.com/uploads/item/201207/28/20120728104206_c5JEu.thumb.700_0.jpeg",
                "https://b-ssl.duitang.com/uploads/item/201703/30/20170330200900_UMCLz.jpeg",
                "https://i0.hdslb.com/bfs/article/7406a34172fd9c73651235ded78ea10147eb23ce.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MZImageBrowsing-CollectionView"
        self.view.addSubview(collectionView)
        collectionView.frame = self.view.bounds
    }


}
