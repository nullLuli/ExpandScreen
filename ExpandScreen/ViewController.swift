//
//  ViewController.swift
//  ExpandScreen
//
//  Created by nullLuli on 2019/3/5.
//  Copyright © 2019 nullLuli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IExpandScreen {
    var expandScreenView: UIScrollView = {
        let view = UIScrollView()
        let size = UIScreen.main.bounds.size
        view.contentSize = CGSize(width: size.width, height: size.height + 64)
        view.bounces = false
        return view
    }()
    
    var lastDirection: Direction = .down
    
    var isAnimate: Bool = false
    
    var offsetThresholdWhenUp: CGFloat {
        return 64
    }
    
    var offsetThresholdWhenDown: CGFloat {
        return 0
    }
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.text = "i am title"
        view.textAlignment = .center
        view.backgroundColor = UIColor.yellow
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        view.addSubview(expandScreenView)
        expandScreenView.addSubview(titleLabel)
        expandScreenView.frame = view.bounds
        titleLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 64)
        
        let childControl = ContentController(expandScreen: self)
        addChild(childControl)
        expandScreenView.addSubview(childControl.view)
        childControl.view.frame = CGRect(x: 0, y: titleLabel.frame.maxY, width: view.frame.width, height: view.frame.height)
        childControl.willMove(toParent: self)
    }
}

class ContentController: UIViewController, IExpandScrollableContent, UITableViewDelegate, UITableViewDataSource {
    weak var expandScreen: IExpandScreen?
    
    var lastOffsetY: CGFloat = 0
    
    var lastDirection: Int = Direction.down.rawValue
    
    let tableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        view.backgroundColor = UIColor.red
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    init(expandScreen: IExpandScreen) {
        self.expandScreen = expandScreen
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
    
    //MARK: Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _ = scrollViewDidScroll_ExpandScreen(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll_ExpandScreen(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll_ExpandScreen(scrollView)
    }
}
