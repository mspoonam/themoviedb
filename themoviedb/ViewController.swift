//
//  ViewController.swift
//  MedlabMovieIOSInterview
//
//  Created by Poonam Pandey on 28/03/18.
//  Copyright © 2018 Poonam Pandey. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: CollectionOfMovies, ReactiveDisposable {
    
    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var placeholderView: UIView!
    fileprivate let refreshControl: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Properties
    
    fileprivate let popularView: PopularModel = PopularModel()
    let disposeBag: DisposeBag = DisposeBag()
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupUI()
        self.setupCollectionView()
        self.setupBindings()
        self.popularView.reloadTrigger.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Reactive bindings setup
    
    fileprivate func setupBindings() {
        
        // Bind refresh control to data reload
        self.refreshControl.rx
            .controlEvent(.valueChanged)
            .filter({ self.refreshControl.isRefreshing })
            .bindTo(self.popularView.reloadTrigger)
            .addDisposableTo(self.disposeBag)
        
        // Bind view model films to the table view
        self.popularView
            .films
            .bindTo(self.collectionView.rx.items(cellIdentifier: MovieCell.DefaultReuseIdentifier, cellType: MovieCell.self)) {
                (row, film, cell) in
                cell.populate(withPosterPath: film.posterPath, andTitle: film.fullTitle)
            }.addDisposableTo(self.disposeBag)
        
        // Bind view model films to the refresh control
        self.popularView.films
            .subscribe { _ in
                self.refreshControl.endRefreshing()
            }.addDisposableTo(self.disposeBag)
        
        // Bind table view bottom reached event to loading the next page
        self.collectionView.rx
            .reachedBottom
            .bindTo(self.popularView.nextPageTrigger)
            .addDisposableTo(self.disposeBag)
        
    }
    
    // MARK: - UI Setup
    
    fileprivate func setupUI() { }
    
    fileprivate func setupCollectionView() {
        self.collectionView.registerReusableCell(MovieCell.self)
        self.collectionView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
        self.collectionView.addSubview(self.refreshControl)
    }
    
    fileprivate func setupScrollViewViewInset(forBottom bottom: CGFloat, animationDuration duration: Double? = nil) {
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
        if let duration = duration {
            UIView.animate(withDuration: duration, animations: {
                self.collectionView.contentInset = inset
                self.collectionView.scrollIndicatorInsets = inset
            })
        } else {
            self.collectionView.contentInset = inset
            self.collectionView.scrollIndicatorInsets = inset
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filmDetailsViewController = segue.destination as? DetailedViewController,
            let customSegue = segue as? PushDetailViewSequeHandler,
            let indexPath = sender as? IndexPath,
            let cell = self.collectionView.cellForItem(at: indexPath) as? MovieCell {
            do {
                let film: MovieItemEntity = try collectionView.rx.model(at: indexPath)
                self.preparePushTransition(to: filmDetailsViewController, with: film, fromCell: cell, via: customSegue)
            } catch { fatalError(error.localizedDescription) }
        }
    }
    
    
}


extension ViewController: UITableViewDelegate {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DetailedViewControllerSeque", sender: indexPath)
    }
}


extension ViewController: CellTransitionCustom {
    public func preparePushTransition(to viewController: DetailedViewController, with film: MovieItemEntity, fromCell cell: MovieCell, via segue: PushDetailViewSequeHandler) {
        
        
        let detailViewModel = PopularDetailModel(withFilmId: film.id)
        viewController.viewModel = detailViewModel
        
        viewController.rx.viewDidLoad.subscribe(onNext: { _ in
            viewController.prePopulate(forFilm: film)
        }).addDisposableTo(disposeBag)
        
        // Setup the segue for transition
        segue.startingFrame = cell.convert(cell.bounds, to: self.view)
        segue.posterImage = cell.filmPosterImageView.image
    }
    
}


