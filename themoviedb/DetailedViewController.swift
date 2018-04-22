//
//  DetailedViewController.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import CoreData


// MARK: -

public final class DetailedViewController: UIViewController, ReactiveDisposable  {
    
    // MARK: - Properties
    
    let disposeBag: DisposeBag = DisposeBag()
    var viewModel: PopularDetailModel?
    var backgroundImagePath: Observable<ImgPath?> = Observable.empty()
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var markFav: UIView!
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var fakeNavigationBar: UIView!
    @IBOutlet weak var fakeNavigationBarHeight: NSLayoutConstraint!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var filmOverviewLabel: UILabel!
    @IBOutlet weak var filmSubDetailsView: UIView!
    @IBOutlet weak var filmRuntimeImageView: UIImageView!
    @IBOutlet weak var filmRuntimeLabel: UILabel!
    @IBOutlet weak var filmRatingImageView: UIImageView!
    @IBOutlet weak var filmRatingLabel: UILabel!
    
    
    // MARK: - UIViewController life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.setupUI()
        
    
        if let viewModel = self.viewModel { self.setupBindings(forViewModel: viewModel) }
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fakeNavigationBarHeight.constant = 89
        
        // Adjust scrollview insets based on film title
        let height: CGFloat = self.view.bounds.width / ImgSize.backdropRatio
        self.scrollView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() {
        self.fakeNavigationBar.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        self.filmTitleLabel.apply(style: .filmDetailTitle)
        self.filmSubDetailsView.alpha = 0.0
        self.filmSubDetailsView.backgroundColor = UIColor(commonColor: .offBlack).withAlphaComponent(0.2)
        self.filmRuntimeImageView.tintColor = UIColor(commonColor: .lightY)
        self.filmRuntimeLabel.apply(style: .filmRating)
        self.filmRatingLabel.apply(style: .filmRating)
        self.filmOverviewLabel.apply(style: .body)
        
    }
    
    
    
    fileprivate func setupCollectionViews() {
        
    }
    
    fileprivate func updateBackdropImageViewHeight(forScrollOffset offset: CGPoint?) {
        if let height = offset?.y {
            self.backdropImageViewHeight.constant = max(0.0, -height)
        } else {
            let height: CGFloat = self.view.bounds.width / ImgSize.backdropRatio
            self.backdropImageViewHeight.constant = max(0.0, height)
        }
    }
    
    // MARK: - Populate
    
    fileprivate func populate(forFilmDetail filmDetail: MovieDetailItemEntity) {
        UIView.animate(withDuration: 0.2) { self.filmSubDetailsView.alpha = 1.0 }
        self.filmRuntimeLabel.text = "Rating - \(filmDetail.voteAverage)/10"
        self.blurredImageView.contentMode = .scaleAspectFill
        if let backdropPath = filmDetail.backdropPath {
            if let posterPath = filmDetail.posterPath { self.blurredImageView.setImage(fromDBPath: posterPath, withSize: .medium) }
            self.backdropImageView.contentMode = .scaleAspectFill
            self.backdropImageView.setImage(fromDBPath: backdropPath, withSize: .medium, animatedOnce: true)
            self.backdropImageView.backgroundColor = UIColor.clear
        } else if let posterPath = filmDetail.posterPath {
            self.blurredImageView.setImage(fromDBPath: posterPath, withSize: .medium)
            self.backdropImageView.contentMode = .scaleAspectFill
            self.backdropImageView.setImage(fromDBPath: posterPath, withSize: .medium)
            self.backdropImageView.backgroundColor = UIColor.clear
        } else {
            self.blurredImageView.image = nil
            self.backdropImageView.contentMode = .scaleAspectFit
            self.backdropImageView.image = #imageLiteral(resourceName: "Logo_Icon")
            self.backdropImageView.backgroundColor = UIColor.groupTableViewBackground
        }
        self.filmTitleLabel.text = filmDetail.fullTitle.uppercased()
        self.filmOverviewLabel.text = filmDetail.overview
       
    }
    
    public func prePopulate(forFilm film: MovieItemEntity) {
        if let posterPath = film.posterPath { self.blurredImageView.setImage(fromDBPath: posterPath, withSize: .medium, animatedOnce: true) }
        self.filmTitleLabel.text = film.fullTitle.uppercased()
        self.filmOverviewLabel.text = film.overview
    }
    
    // MARK: - Reactive setup
    
    fileprivate func setupBindings(forViewModel viewModel: PopularDetailModel) {
        
        viewModel
            .filmDetail
            .subscribe(onNext: { [weak self] (filmDetail) in
                self?.populate(forFilmDetail: filmDetail)
            }).addDisposableTo(self.disposeBag)
        
        self.backgroundImagePath = viewModel.filmDetail.map { (filmDetail) -> ImgPath? in
            return filmDetail.posterPath ?? filmDetail.backdropPath
        }
        
        self.scrollView.rx.contentOffset.subscribe { [weak self] (contentOffset) in
            self?.updateBackdropImageViewHeight(forScrollOffset: contentOffset.element)
            }.addDisposableTo(self.disposeBag)
        
        self.unMarkFavourite()
        if self.fetchIdAndCheck(id: viewModel.filmId) {
            self.markFavourite()
        }
        
        let gestureFavourite = UITapGestureRecognizer()
        gestureFavourite.rx.event.bindNext{ recognizer in
                self.save(id: viewModel.filmId)
            }.addDisposableTo(self.disposeBag)
        
        self.markFav.addGestureRecognizer(gestureFavourite)
    }
    
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func save(id:Int)
    {
        guard self.filmRatingImageView.tag == 0 else {
            self.unMarkFavourite()
            self.deleteIt(id: id)
            return
        }
        let idEntity = NSEntityDescription.entity(forEntityName: "PopluarEntity", in: getManagedContext())!
        let user = NSManagedObject(entity: idEntity, insertInto: getManagedContext())
        user.setValue(id, forKeyPath: "filmid")
        do {
            try getManagedContext().save()
            self.markFavourite()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func fetchIdAndCheck(id: Int)->Bool{
        let fetchRequest =  NSFetchRequest<NSManagedObject>(entityName: "PopluarEntity")
        do {
            fetchRequest.predicate = NSPredicate(format: "filmid == %d", id)
            let fetchedResults = try getManagedContext().fetch(fetchRequest)
            
            if fetchedResults.count>0 {
                print("found PopluarEntity")
                return true
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func deleteIt(id: Int) {
        
        let fetchRequest =  NSFetchRequest<NSManagedObject>(entityName: "PopluarEntity")
        
        do {
            fetchRequest.predicate = NSPredicate(format: "filmid == %d", id)
            let fetchedResults = try getManagedContext().fetch(fetchRequest)
            if fetchedResults.count>0 {
                for entity in fetchedResults {
                    getManagedContext().delete(entity)
                }
                try getManagedContext().save()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    fileprivate func getManagedContext()->NSManagedObjectContext{
        return ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    }
    
    fileprivate func markFavourite(){
        self.filmRatingImageView.image = UIImage(named: "marked_stars")
        self.filmRatingImageView.tag = 1
    }
    
    fileprivate func unMarkFavourite(){
        self.filmRatingImageView.image = UIImage(named: "unmark_stars")
        self.filmRatingImageView.tag = 0
    }
}





