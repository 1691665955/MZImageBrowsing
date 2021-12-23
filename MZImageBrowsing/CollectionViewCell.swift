//
//  CollectionViewCell.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.contentView.addSubview(self.imageView)
    }
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
    
    func setUrl(url: String) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: URL(string: url)!)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
}
