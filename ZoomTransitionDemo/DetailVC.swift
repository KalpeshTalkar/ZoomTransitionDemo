//
//  DetailVC.swift
//  ZoomTransitionDemo
//
//  Created by Kalpesh on 14/05/17.
//  Copyright © 2017 Infini. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, ZoomingViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var imageVIew: UIImageView!
    var image: UIImage?

    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imageVIew.image = image
    }

    // MARK: - ZoomingViewController
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        return imageVIew
    }

    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }

}
