//
//  CommentsViewController.swift
//  TopComments
//
//  Created by  Oleksandra on 1/27/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit

class CommentsViewController: UITableViewController {

    var comments = [Comment]()
    var startId = 0
    var endId = 0
    
    private var currentStartId = 0
    private var currentEndId = 0
    
    private let paginationConst = 10
    private var needsPagination = true
    private var isFirstPage = true
    
    private let commentCellId = "CommentCell"
    private let loadingCellId = "LoadingCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRange()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isFirstPage = !isFirstPage
    }
    
    func configureView() {
        tableView.backgroundView = UIImageView(image: UIImage(named: "bg_tableview"))
        tableView.backgroundView?.contentMode = .scaleAspectFill
        navigationItem.title = "Comments"
        
        var nib = UINib(nibName: commentCellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: commentCellId)
        
        nib = UINib(nibName: loadingCellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: loadingCellId)
    }
    
    func configureRange() {
        
        //count lower and upper bounds to fetch first after the result
        
        currentStartId = startId + paginationConst
        currentEndId = min(currentStartId + paginationConst, endId)
        needsPagination = (endId - startId) > paginationConst
    }
    
    func countRange() {
        
        //count new lower and upper bounds of the next page to fetch
        
        if (endId - currentStartId) > paginationConst {
            needsPagination = true
            currentStartId = currentStartId + paginationConst
            currentEndId = min(currentStartId + paginationConst, endId)
        } else {
            needsPagination = false
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return needsPagination ? (comments.count + 1) : comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == comments.count && needsPagination {
            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellId, for: indexPath) as! LoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentCell
            cell.configureCellFor(comment: comments[indexPath.row])
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //fetching a new page when scrolled to the bottom of the current page
         if !isFirstPage && needsPagination && cell.isKind(of: LoadingCell.self) {
            fetchNextPage()
            countRange()
        }
    }
    
    private func fetchNextPage() {
        NetworkService().fetchCommentsFrom(currentStartId, to: currentEndId, completion: { [weak self] page in
            DispatchQueue.main.async {
                guard let comments = page else {
                    self?.presentAlert(with: "Network error")
                    return
                }
                self?.comments.append(contentsOf: comments)
                self?.tableView.reloadData()
            }
        })
    }
    
    private func presentAlert(with message: String) {
        let alertController = UIAlertController(title: "Attention!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
