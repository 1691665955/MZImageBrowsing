//
//  TableViewCell.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/23.
//

import UIKit

class TableViewCell: UITableViewCell {

    lazy var iconView1: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 20, y: 20, width: SCREEN_WIDHT / 2 - 30, height: SCREEN_WIDHT / 2 - 30))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var iconView2: UIImageView = {
        let view = UIImageView(frame: CGRect(x: SCREEN_WIDHT / 2 + 10, y: 20, width: SCREEN_WIDHT / 2 - 30, height: SCREEN_WIDHT / 2 - 30))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var preview: ((_ index: Int, _ imageView: UIImageView)->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.selectionStyle = .none
        self.contentView.addSubview(self.iconView1)
        self.contentView.addSubview(self.iconView2)
        
        let tap1 = UITapGestureRecognizer.init(target: self, action: #selector(previewImage(_:)))
        self.iconView1.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer.init(target: self, action: #selector(previewImage(_:)))
        self.iconView2.addGestureRecognizer(tap2)
    }
    
    @objc func previewImage(_ tap: UITapGestureRecognizer) {
        if let myPreview = self.preview {
            myPreview(tap.view == self.iconView1 ? 0 : 1, tap.view == self.iconView1 ? self.iconView1 : self.iconView2)
        }
        
    }
    
    func setImages(images: [UIImage]) {
        self.iconView1.image = images[0]
        self.iconView2.image = images[1]
    }
    
    func setUrl(urls: [String]) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: URL(string: urls[0])!)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.iconView1.image = image
                }
            } catch {
                print(error)
            }
        }
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: URL(string: urls[1])!)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.iconView2.image = image
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
