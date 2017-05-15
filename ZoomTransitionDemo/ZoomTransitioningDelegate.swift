//
//  ZoomTransitioningDelegate.swift
//  ZoomTransitionDemo
//
//  Created by Kalpesh on 14/05/17.
//  Copyright © 2017 Infini. All rights reserved.
//

import UIKit

protocol ZoomingViewController {
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView?
    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView?
}

enum TransitionState {
    case initial
    case final
}

class ZoomTransitioningDelegate: NSObject {

    var transitionDuration = 0.5
    var operation: UINavigationControllerOperation = .none
    private let zoomScale = CGFloat(15)
    private let backgroundScale = CGFloat(0.8)

    typealias ZoomingViews = (otherView: UIView, imageView: UIView)

    func configureViews(for state: TransitionState, containerView: UIView, backGroundVC: UIViewController, viewsInBackground: ZoomingViews, viewsInForeground: ZoomingViews, snapshotViews: ZoomingViews) {
        switch state {
        case .initial:
            // set the initial state of the background view and its image view
            backGroundVC.view.transform = CGAffineTransform.identity
            backGroundVC.view.alpha = 1
            snapshotViews.imageView.frame = containerView.convert(viewsInBackground.imageView.frame, from: viewsInBackground.imageView.superview)

        case .final:
            // make the background view shrink down to backgroundScale
            backGroundVC.view.transform = CGAffineTransform(scaleX: backgroundScale, y: backgroundScale)
            backGroundVC.view.alpha = 0
            snapshotViews.imageView.frame = containerView.convert(viewsInForeground.imageView.frame, from: viewsInForeground.imageView.superview)
        }
    }

}

extension ZoomTransitioningDelegate: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView

        // check operation type
        var backgroundViewController = fromViewController
        var foregroundViewController = toViewController

        if operation == .pop {
            backgroundViewController = toViewController
            foregroundViewController = fromViewController
        }

        // get the imageview or any views to animate
        let maybeBackgroundImageView = (backgroundViewController as? ZoomingViewController)?.zoomingImageView(for: self)
        let maybeForegroundImageView = (foregroundViewController as? ZoomingViewController)?.zoomingImageView(for: self)

        assert(maybeBackgroundImageView != nil, "Cannot find image view in backgroundVC in ZoomingTransitioningDelegate")
        assert(maybeForegroundImageView != nil, "Cannot find image view in foregroundVC in ZoomingTransitioningDelegate")

        let backgroundImageView = maybeBackgroundImageView!
        let foregroundImageView = maybeForegroundImageView!

        // create some view snapshots
        let imageViewSnapshot = UIImageView(image: backgroundImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFill
        imageViewSnapshot.layer.masksToBounds = true

        // setup animation
        backgroundImageView.isHidden = true
        foregroundImageView.isHidden = true
        let foregroundViewBackgroundColor = foregroundViewController.view.backgroundColor
        foregroundViewController.view.backgroundColor = UIColor.clear
        containerView.backgroundColor = UIColor.white
        containerView.addSubview(backgroundViewController.view)
        containerView.addSubview(foregroundViewController.view)
        containerView.addSubview(imageViewSnapshot)

        // set up transition state - we check if it's pop or push. Then we use .final or .initial to use our helper method to set the backgroundVC's view and imageView initial state
        var preTransitionState = TransitionState.initial
        var postTransitionState = TransitionState.final

        if operation == .pop {
            preTransitionState = .final
            postTransitionState = .initial
        }

        // Use our configureViews helper method to set the initial state of the transition.
        configureViews(for: preTransitionState, containerView: containerView, backGroundVC: backgroundViewController, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))

        // during the transition, the device can be rotated or subviews can be changed so we call this to make sure everything is ok before we animate stuff.
        foregroundViewController.view.layoutIfNeeded()

        // We use UIView's animate method to animate from the initial state to the final state. We use the configureViews method again to help us with this.
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.configureViews(for: postTransitionState, containerView: containerView, backGroundVC: backgroundViewController, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        }) { (finished) in
            backgroundViewController.view.transform = CGAffineTransform.identity
            imageViewSnapshot.removeFromSuperview()
            backgroundImageView.isHidden = false
            foregroundImageView.isHidden = false
            foregroundViewController.view.backgroundColor = foregroundViewBackgroundColor
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}

extension ZoomTransitioningDelegate: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is ZoomingViewController && toVC is ZoomingViewController {
            self.operation = operation
            return self
        } else {
            return nil
        }
    }

}
