//
//  FeedHostController.swift
//  AlMurray
//
//  Created by Tom Knighton on 12/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class FeedHostController: UITableViewController {
    
    var aditLogs: [AditLog] = []
    var postsToDisplay: [FeedPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        FeedService().getFeedPosts { (posts) in
            if let posts = posts {
                DispatchQueue.main.async {
                    self.postsToDisplay = posts
                    self.tableView.reloadData()
                }
            }
        }
        
        FeedService().getAditLogs { (aditlogs) in
            if let aditlogs = aditlogs {
                DispatchQueue.main.async {
                    self.aditLogs = aditlogs
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsToDisplay.count + 1
        // Posts + Adit logs row
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let aditLogCell = self.tableView.dequeueReusableCell(withIdentifier: "FeedAditLogContainerCell") as? FeedAditLogContainerCell else { print("err"); return UITableViewCell() }
            aditLogCell.setup(for: self.aditLogs)
            return aditLogCell
        }
        
        let post = self.postsToDisplay[indexPath.row - 1]
        if post is FeedMediaPost {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "FeedPostCell", for: indexPath) as? FeedPostMediaCell else { return UITableViewCell() }
            guard let post = post as? FeedMediaPost else { return UITableViewCell() }
            
            cell.setup(for: post)
            return cell
        } else if post is FeedPollPost {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "FeedPollCell", for: indexPath) as? FeedPostPollCell else { return UITableViewCell() }
            guard let post = post as? FeedPollPost else { return UITableViewCell() }
            
            cell.setup(for: post)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        let post = self.postsToDisplay[indexPath.row - 1]
        if post is FeedMediaPost && post.postType == "Video" {
            guard let videoCell = cell as? FeedPostMediaCell else { return }
            
            let visibleCells = self.tableView.visibleCells
            let minIndex = visibleCells.startIndex
            if visibleCells.firstIndex(of: cell) == minIndex {
                videoCell.avPlayer?.play()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        let post = self.postsToDisplay[indexPath.row - 1]
        if post is FeedMediaPost && post.postType == "Video" {
            guard let videoCell = cell as? FeedPostMediaCell else { return }
            
            videoCell.avPlayer?.pause()
            videoCell.avPlayer = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let visibleCells = self.tableView.visibleCells
        visibleCells.forEach { (cell) in
            if self.tableView.indexPath(for: cell)?.row == 0 { return }
            let post = self.postsToDisplay[(self.tableView.indexPath(for: cell)?.row ?? 1) - 1]
            if post is FeedMediaPost && post.postType == "Video" {
                guard let videoCell = cell as? FeedPostMediaCell else { return }
                
                videoCell.avPlayer?.pause()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let visibleCells = self.tableView.visibleCells
        visibleCells.forEach { (cell) in
            if self.tableView.indexPath(for: cell)?.row == 0 { return }
            let post = self.postsToDisplay[(self.tableView.indexPath(for: cell)?.row ?? 0) - 1]
            if post is FeedMediaPost && post.postType == "Video" {
                guard let videoCell = cell as? FeedPostMediaCell else { return }
                
                videoCell.playVideo()
            }
        }
    }

}
