//
//  MZImageBrowsingTransitioning.swift
//  MZImageBrowsing
//
//  Created by 曾龙 on 2021/12/22.
//

import UIKit

enum MZImageBrowsingTransitioningType {
    case Present
    case Dismiss
}

let SCREEN__WIDTH = UIScreen.main.bounds.size.width
let SCREEN__HEIGHT = UIScreen.main.bounds.size.height


class MZImageBrowsingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var type: MZImageBrowsingTransitioningType
    
    init(type: MZImageBrowsingTransitioningType) {
        self.type = type
    }
    
    static func transition(withTransitionType type: MZImageBrowsingTransitioningType) -> MZImageBrowsingTransitioning {
        return MZImageBrowsingTransitioning(type: type)
    }
    
    //MARK:- UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch self.type {
        case .Present:
            self.presentAnimation(transitionContext)
        case .Dismiss:
            self.dismissAnimation(transitionContext)
        }
    }
    
    //MARK:- PRIVATE
    private func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to) as! MZImageBrowsingController
        var fromVC = transitionContext.viewController(forKey: .from)!
        if fromVC.isKind(of: UINavigationController.classForCoder()) {
            fromVC = (fromVC as! UINavigationController).viewControllers.last!
        }
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .black
        let tempImageView = UIImageView()
        tempImageView.image = toVC.currentImageView?.image
        tempImageView.contentMode = .scaleAspectFill
        tempImageView.clipsToBounds = true;
        containerView.addSubview(toVC.view)
        containerView.addSubview(tempImageView)
        tempImageView.frame = self.getViewFrameInScrren(toVC.currentImageView!)
        fromVC.view.isHidden = true
        toVC.view.isHidden = true
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            tempImageView.frame = CGRect(x: 0, y: 0, width: SCREEN__WIDTH, height: SCREEN__WIDTH * (toVC.currentImageView?.image?.size.height)! / (toVC.currentImageView?.image?.size.width)!)
            tempImageView.center = toVC.view.center;
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            tempImageView.isHidden = true
            toVC.view.isHidden = false
            fromVC.view.isHidden = false
            tempImageView.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                fromVC.view.isHidden = false
            }
        }
    }
    
    private func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! MZImageBrowsingController
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .clear
        let tempImageView = UIImageView()
        tempImageView.image = fromVC.showImageView.image
        tempImageView.frame = fromVC.showImageView.frame
        tempImageView.contentMode = .scaleAspectFill
        tempImageView.clipsToBounds = true;
        containerView.addSubview(tempImageView)
        fromVC.view.alpha = 1
        fromVC.currentImageView!.isHidden = true
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            tempImageView.frame = self.getViewFrameInScrren(fromVC.currentImageView!)
            fromVC.view.alpha = 0
        } completion: { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if !transitionContext.transitionWasCancelled {
                tempImageView.removeFromSuperview()
                fromVC.currentImageView?.isHidden = false
            }
        }
    }
    
    private func getViewFrameInScrren(_ view: UIView) -> CGRect {
        guard let superView = view.superview else {
            return view.frame
        }
        let window = UIApplication.shared.delegate?.window!
        return superView.convert(view.frame, to: window)
    }
}
