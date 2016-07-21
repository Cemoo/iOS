//
//  ViewController.swift
//  TUM Campus App
//
//  Created by Mathias Quintero on 10/28/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import MCSwipeTableViewCell

class CardViewController: UITableViewController {
    
    var manager: TumDataManager?
    
    var cards = [DataElement]()
    
    var nextLecture: CalendarRow?
    
    var refresh = UIRefreshControl()
    
    func refresh(sender: AnyObject?) {
        manager?.getCardItems(self)
    }
    
}

extension CardViewController: ImageDownloadSubscriber, DetailViewDelegate {
    
    func updateImageView() {
        tableView.reloadData()
    }
    
    func dataManager() -> TumDataManager {
        return manager ?? TumDataManager(user: nil)
    }
    
}

extension CardViewController: TumDataReceiver {
    
    func receiveData(data: [DataElement]) {
        if cards.count <= data.count {
            for item in data {
                if let movieItem = item as? Movie {
                    movieItem.subscribeToImage(self)
                }
                if let lectureItem = item as? CalendarRow {
                    nextLecture = lectureItem
                }
            }
            cards = data
            tableView.reloadData()
        }
        refresh.endRefreshing()
    }
    
}

extension CardViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "logo-blue")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView = imageView
        if let bounds = imageView.superview?.bounds {
            imageView.frame = CGRectMake(bounds.origin.x+10, bounds.origin.y+10, bounds.width-20, bounds.height-20)
        }
        refresh.addTarget(self, action: #selector(CardViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresh)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        imageView.clipsToBounds = true
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorColor = UIColor.clearColor()
        tableView.backgroundColor = Constants.backgroundGray
        manager = (self.tabBarController as? CampusTabBarController)?.manager
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cards.removeAll()
        refresh(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var mvc = segue.destinationViewController as? DetailView {
            mvc.delegate = self
        }
        if let mvc = segue.destinationViewController as? CalendarViewController {
            mvc.nextLectureItem = nextLecture
        }
    }
    
}

extension CardViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = cards[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(item.getCellIdentifier()) as? CardTableViewCell ?? CardTableViewCell()
        cell.setElement(item)
        let handler = { () -> () in
            if let path = self.tableView.indexPathForCell(cell) {
                self.cards.removeAtIndex(path.row)
                self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Top)
            }
        }
        cell.selectionStyle = .None
        cell.defaultColor = tableView.backgroundColor
        cell.setSwipeGestureWithView(UIView(), color: tableView.backgroundColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State1) { (void) in handler() }
        cell.setSwipeGestureWithView(UIView(), color: tableView.backgroundColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State2) { (void) in handler() }
        cell.setSwipeGestureWithView(UIView(), color: tableView.backgroundColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State3) { (void) in handler() }
        cell.setSwipeGestureWithView(UIView(), color: tableView.backgroundColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State4) { (void) in handler() }
        return cell
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}

