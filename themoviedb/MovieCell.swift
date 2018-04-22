//
//  MovieCell.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit

public final class MovieCell: UICollectionViewCell {
    
    // MARK: - IBOutlet properties
    
    //    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var filmPosterImageView: UIImageView!
    
    // MARK: - UICollectionViewCell life cycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        //        self.filmTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
    }
    
    // MARK: -
    
    func populate(withPosterPath posterPath: ImgPath?, andTitle title: String) {
        //        self.filmTitleLabel.text = title
        self.filmPosterImageView.image = nil
        if let posterPath = posterPath {
            self.filmPosterImageView.setImage(fromDBPath: posterPath, withSize: .medium, animatedOnce: true)
        }
    }
}

extension MovieCell: NibLoadableView { }

extension MovieCell: ReusableView { }
