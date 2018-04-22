//
//  CollectionOfMovies.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit

public class CollectionOfMovies: UIViewController {
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - UIViewController handling
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionViewItemsPerRow = self.itemsPerRow(for: UIScreen.main.bounds.size)
    }
    
    // MARK: - Rotation handling
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard self.isViewLoaded else { return }
        self.collectionViewItemsPerRow = self.itemsPerRow(for: size)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    fileprivate func itemsPerRow(for size: CGSize) -> Int {
        return 1
    }
    // MARK: - UICollectionViewCell layout properties
    
    fileprivate var collectionViewItemsPerRow: Int = 2
    fileprivate let collectionViewMargin: CGFloat = 15.0
    fileprivate let collectionViewItemSizeRatio: CGFloat = ImgSize.posterRatio
    fileprivate var collectionViewItemWidth: CGFloat {
        return (self.collectionView.bounds.width - (CGFloat(self.collectionViewItemsPerRow + 1) * self.collectionViewMargin)) / CGFloat(self.collectionViewItemsPerRow)
    }
    fileprivate var collectionViewItemHeight: CGFloat {
        return self.collectionViewItemWidth / self.collectionViewItemSizeRatio
    }
}

// MARK: -

extension CollectionOfMovies: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewItemWidth, height: self.collectionViewItemHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.collectionViewMargin, left: self.collectionViewMargin, bottom: self.collectionViewMargin, right: self.collectionViewMargin)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.collectionViewMargin
    }
}

