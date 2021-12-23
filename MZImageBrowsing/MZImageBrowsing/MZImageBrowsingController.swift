//
//  MZImageBrowsingController.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/22.
//

import UIKit

class MZImageBrowsingController: UIViewController, UIViewControllerTransitioningDelegate, UIScrollViewDelegate {
    
    lazy var showImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    var currentImageView: UIImageView?
    
    private var imageViewList: [UIImageView]?
    private var imageUrlList: [String]?
    private var currentIndex: Int?
    private lazy var contentView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN__WIDTH+20, height: SCREEN__HEIGHT))
        scrollView.delegate = self
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = false
        scrollView.backgroundColor = .black
        scrollView.contentSize = CGSize(width: (20 + SCREEN__WIDTH) * CGFloat((self.imageViewList == nil ? self.imageUrlList?.count : self.imageViewList?.count)!), height: SCREEN__HEIGHT)
        scrollView.isPagingEnabled = true
        scrollView.isDirectionalLockEnabled = true
        return scrollView
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    init(imageViewList: [UIImageView], currentIndex: Int) {
        self.init()
        self.imageViewList = imageViewList
        self.currentIndex = currentIndex
        self.currentImageView = imageViewList[currentIndex]
    }
    
    init(imageUrlList: [String], currentImageView: UIImageView, currentIndex: Int) {
        self.init()
        self.imageUrlList = imageUrlList
        self.currentImageView = currentImageView
        self.currentIndex = currentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    //MARK:- PRIVATE
    private func initUI() {
        self.view.backgroundColor = .black
        self.view.addSubview(contentView)
        
        if #available(iOS 11.0, *) {
            self.contentView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        for i in 0..<((self.imageViewList == nil ? self.imageUrlList?.count : self.imageViewList?.count)!) {
            let scrollView = UIScrollView.init(frame: CGRect(x: (SCREEN__WIDTH + 20) * CGFloat(i), y: 0, width: SCREEN__WIDTH, height: SCREEN__HEIGHT))
            scrollView.tag = 100 + i
            scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: SCREEN__HEIGHT)
            scrollView.maximumZoomScale = 3
            scrollView.minimumZoomScale = 1
            scrollView.zoomScale = 1
            scrollView.delegate = self
            self.contentView.addSubview(scrollView)
            
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            
            let containerView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__HEIGHT))
            scrollView.addSubview(containerView)
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(back))
            containerView.addGestureRecognizer(tap)
            
            if let list = self.imageViewList {
                let tempImageView = list[i]
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (tempImageView.image?.size.height)! / (tempImageView.image?.size.width)!))
                if imageView.frame.height <= SCREEN__HEIGHT {
                    imageView.center = CGPoint(x: SCREEN__WIDTH / 2, y: SCREEN__HEIGHT / 2)
                    scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: SCREEN__HEIGHT)
                } else {
                    var frame = containerView.frame
                    frame.size.height = imageView.frame.height
                    containerView.frame = frame
                    scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: imageView.frame.height)
                }
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.image = tempImageView.image
                containerView.addSubview(imageView)
                
                if i == self.currentIndex {
                    self.showImageView.image = tempImageView.image
                    self.showImageView.frame = CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (tempImageView.image?.size.height)! / (tempImageView.image?.size.width)!)
                    self.showImageView.center = self.view.center
                }
            } else if let list = self.imageUrlList {
                let url = list[i]
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__HEIGHT))
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                containerView.addSubview(imageView)
                self.downloadImage(url: url, imageView: imageView, scrollView: scrollView, containerView: contentView)
                
                if i == self.currentIndex {
                    self.showImageView.image = self.currentImageView?.image
                    self.showImageView.frame = CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (self.currentImageView!.image?.size.height)! / (self.currentImageView!.image?.size.width)!)
                    self.showImageView.center = self.view.center
                }
            }
        }
        self.contentView.setContentOffset(CGPoint(x: (20 + SCREEN__WIDTH) * CGFloat(self.currentIndex!), y: 0), animated: false)
    }
    
    @objc private func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func zoom(_ pinch: UIPinchGestureRecognizer) {
        let scrollView = pinch.view?.superview as! UIScrollView
        scrollView.zoomScale = pinch.scale
    }
    
    func downloadImage(url: String, imageView: UIImageView, scrollView: UIScrollView, containerView: UIView) {
        guard let link = URL(string: url) else {
            return
        }
        URLSession.shared.dataTask(with: link) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async {
                imageView.image = image
                imageView.frame = CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * image.size.height / image.size.width)
                if imageView.frame.height <= SCREEN__HEIGHT {
                    imageView.center = CGPoint(x: SCREEN__WIDTH / 2, y: SCREEN__HEIGHT / 2)
                    scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: SCREEN__HEIGHT)
                } else {
                    var frame = containerView.frame
                    frame.size.height = imageView.frame.height
                    containerView.frame = frame
                    scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: imageView.frame.height)
                }
            }
        }.resume()
    }
    
    //MARK:- UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MZImageBrowsingTransitioning.transition(withTransitionType: .Present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MZImageBrowsingTransitioning.transition(withTransitionType: .Dismiss)
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != self.contentView {
            return
        }
        self.currentIndex = Int(scrollView.contentOffset.x / (SCREEN__WIDTH + 20.0))
        if self.imageViewList != nil {
            let tempImageView = self.imageViewList![self.currentIndex!]
            self.currentImageView = tempImageView
            self.showImageView.image = tempImageView.image
            self.showImageView.frame = CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (tempImageView.image?.size.height)! / (tempImageView.image?.size.width)!)
            self.showImageView.center = self.view.center
        } else {
            let tempImageView = scrollView.viewWithTag(100 + self.currentIndex!)?.subviews.first?.subviews.first as! UIImageView
            self.showImageView.image = tempImageView.image
            self.showImageView.frame = CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (tempImageView.image?.size.height)! / (tempImageView.image?.size.width)!)
            self.showImageView.center = self.view.center
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView != self.contentView {
            return scrollView.subviews.last
        }
        return nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
