//
//  MZImageBrowsingController.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/22.
//

import UIKit
import Photos

open class MZImageBrowsingController: UIViewController, UIViewControllerTransitioningDelegate, UIScrollViewDelegate {
    
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
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(back))
        scrollView.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(scaleOrReset))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
        
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(saveImage))
        scrollView.addGestureRecognizer(longTap)
        
        return scrollView
    }()
    
    public required init?(coder: NSCoder) {
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
    
    public init(imageViewList: [UIImageView], currentIndex: Int) {
        self.init()
        self.imageViewList = imageViewList
        self.currentIndex = currentIndex
        self.currentImageView = imageViewList[currentIndex]
    }
    
    public init(imageUrlList: [String], currentImageView: UIImageView, currentIndex: Int) {
        self.init()
        self.imageUrlList = imageUrlList
        self.currentImageView = currentImageView
        self.currentIndex = currentIndex
    }
    
    open override func viewDidLoad() {
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
            
            if let list = self.imageViewList {
                let tempImageView = list[i]
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (tempImageView.image?.size.height)! / (tempImageView.image?.size.width)!))
                if imageView.frame.height <= SCREEN__HEIGHT {
                    imageView.center = CGPoint(x: SCREEN__WIDTH / 2, y: SCREEN__HEIGHT / 2)
                    scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: SCREEN__HEIGHT)
                } else {
                    scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: imageView.frame.height)
                }
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.image = tempImageView.image
                scrollView.addSubview(imageView)
                
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
                scrollView.addSubview(imageView)
                self.downloadImage(url: url, imageView: imageView, scrollView: scrollView)
                
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
    
    @objc private func scaleOrReset(_ tap: UITapGestureRecognizer) {
        let scrollView = self.contentView.viewWithTag(100 + self.currentIndex!) as! UIScrollView
        if scrollView.zoomScale < 1.5 {
            scrollView.setZoomScale(2, animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    @objc private func saveImage() {
        let image = self.showImageView.image!
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = {(_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ activityError: Error?) -> Void in
            if activityType == .saveToCameraRoll {
                if completed {
                    let alert = UIAlertController.init(title: nil, message: "存储成功", preferredStyle: .alert)
                    self.present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    let alert = UIAlertController.init(title: "存储失败", message: "请打开 设置-隐私-照片 来进行设置", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { action in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        controller.excludedActivityTypes = [
            .addToReadingList,
            .postToFacebook,
            .postToTwitter,
            .copyToPasteboard,
            .assignToContact,
            .postToVimeo,
            .openInIBooks,
            .postToFlickr,
        ]
        if #available(iOS 11.0, *) {
            controller.excludedActivityTypes?.append(.markupAsPDF)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    private func downloadImage(url: String, imageView: UIImageView, scrollView: UIScrollView) {
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
                    scrollView.contentSize = CGSize(width: SCREEN__WIDTH, height: imageView.frame.height)
                }
            }
        }.resume()
    }
    
    //MARK:- UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MZImageBrowsingTransitioning.transition(withTransitionType: .Present)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MZImageBrowsingTransitioning.transition(withTransitionType: .Dismiss)
    }
    
    //MARK:- UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
            let tempImageView = scrollView.viewWithTag(100 + self.currentIndex!)?.subviews.first as! UIImageView
            self.showImageView.image = tempImageView.image
            self.showImageView.frame = CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (tempImageView.image?.size.height)! / (tempImageView.image?.size.width)!)
            self.showImageView.center = self.view.center
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView != self.contentView {
            return scrollView.subviews.first
        }
        return nil
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let targetView = self.viewForZooming(in: scrollView)!
        let widthIsSamll = targetView.frame.width < scrollView.frame.width
        let heightIsSamll = targetView.frame.height < scrollView.frame.height

        if widthIsSamll {
            var center = targetView.center
            center.x = scrollView.frame.width / 2
            targetView.center = center
        } else {
            var frame = targetView.frame
            frame.origin.x = 0
            targetView.frame = frame
        }
        
        if heightIsSamll {
            var center = targetView.center
            center.y = scrollView.frame.height / 2
            targetView.center = center
        } else {
            var frame = targetView.frame
            frame.origin.y = 0
            targetView.frame = frame
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
