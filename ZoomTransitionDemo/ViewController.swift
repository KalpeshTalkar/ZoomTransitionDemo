//
//  ViewController.swift
//  ZoomTransitionDemo
//
//  Created by Kalpesh on 12/05/17.
//  Copyright © 2017 Infini. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ZoomingViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - IBOutlets
    @IBOutlet weak var collection: UICollectionView!

    // MARK: - variables
    private let ItemSpacing: CGFloat = 1
    private let LineSpacing: CGFloat = 1
    private let Columns: CGFloat = 4
    private var selectedIndexPath: IndexPath?

    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configure3DTouch()
    }

    // MARK: - UICollectionView Setup
    private func setupCollectionView() {
        let Inset: CGFloat = 1
        collection.contentInset = UIEdgeInsetsMake(Inset, Inset, Inset, Inset)
        collection.dataSource = self
        collection.delegate = self
        collection.reloadData()
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        vc.image = cell.imageView.image
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let leftInset = collectionView.contentInset.left
        let rightInset = collectionView.contentInset.right
        let itemSpacing = Columns - 1
        let availableWidth = screenWidth - leftInset - rightInset - itemSpacing
        let itemWidth = availableWidth/Columns
        return CGSize(width: itemWidth, height: itemWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ItemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LineSpacing
    }

    // MARK: - ZoomingViewController
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        if nil != selectedIndexPath {
            if let cell = collection.cellForItem(at: selectedIndexPath!) as? PhotoCell {
                return cell.imageView
            }
        }
        return nil
    }

    func zoomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }

}

extension ViewController: UIViewControllerPreviewingDelegate {

    func configure3DTouch() {
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self, sourceView: self.view)
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // check if we're not already showing a preview
        if presentedViewController != nil && presentedViewController! is DetailVC {
            return nil
        }

        guard let indexPath = collection.indexPathForItem(at: location),
            let cell = collection.cellForItem(at: indexPath) as? PhotoCell else { return nil }
        // return preview vc
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        vc.image = cell.imageView.image
        return vc
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //show(viewControllerToCommit, sender: self)
    }

}

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.groupTableViewBackground
    }

}
