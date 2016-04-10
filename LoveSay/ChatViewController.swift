//
//  ViewController.swift
//  LoveSay
//
//  Created by Scott Love on 4/9/16.
//  Copyright © 2016 Scott Love. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {
    
    private let tableView = UITableView(frame:CGRectZero, style: .Grouped)
    private let newMessageArea = UIView()
    private let newMessageField = UITextView()
    private let sendButton = UIButton()
    
    private var sections = [NSDate: [Message]]()
    private var dates =  [NSDate]()
    private var bottomConstraint: NSLayoutConstraint!
    private let cellIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMockData()
        initNewMessageField()
        initNewMessageArea()
        initTableViewWithConstraints()
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector:#selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(ChatViewController.handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
    override func viewDidAppear(animated: Bool) {
        tableView.scrollToBottom()
    }
    
    func initTableViewWithConstraints(){
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            tableView.bottomAnchor.constraintEqualToAnchor(newMessageArea.topAnchor)
        ]
        NSLayoutConstraint.activateConstraints(tableViewConstraints)
    }
    
    func initNewMessageArea(){
        newMessageArea.backgroundColor = UIColor.lightGrayColor()
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newMessageArea)
        bottomConstraint = newMessageArea.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        bottomConstraint.active = true
        let newMessageAreaConstraints : [NSLayoutConstraint] = [
            newMessageArea.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            newMessageArea.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            newMessageField.leadingAnchor.constraintEqualToAnchor(newMessageArea.leadingAnchor, constant: 10),
            newMessageField.centerYAnchor.constraintEqualToAnchor(newMessageArea.centerYAnchor),
            sendButton.trailingAnchor.constraintEqualToAnchor(newMessageArea.trailingAnchor, constant: -10),
            newMessageField.trailingAnchor.constraintEqualToAnchor(sendButton.leadingAnchor, constant: -10),
            sendButton.centerYAnchor.constraintEqualToAnchor(newMessageField.centerYAnchor),
            newMessageArea.heightAnchor.constraintEqualToAnchor(newMessageField.heightAnchor, constant:20)
            
        ]
        NSLayoutConstraint.activateConstraints(newMessageAreaConstraints)
    }
    func initNewMessageField(){
        newMessageField.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(newMessageField)
        newMessageField.scrollEnabled = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(sendButton)
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(ChatViewController.pressedSend(_:)), forControlEvents:.TouchUpInside)
        sendButton.setContentHuggingPriority(251, forAxis: .Horizontal)
        sendButton.setContentCompressionResistancePriority(751, forAxis: .Horizontal)
        
    }
    func keyboardWillShow(notification: NSNotification){
        updateBottomConstraint(notification)
    }
    func keyboardWillHide(notification: NSNotification){
        updateBottomConstraint(notification)
        
    }
    func updateBottomConstraint(notification: NSNotification){
        if let
            userInfo = notification.userInfo,
            frame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
            animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue{
            let newFrame = view.convertRect(frame, fromView: (UIApplication.sharedApplication().delegate?.window)!)
            bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(view.frame)
            UIView.animateWithDuration(animationDuration, animations: {self.view.layoutIfNeeded()})
            tableView.scrollToBottom()
        }
    }
    
    func addMessage(message: Message){
        guard let date = message.timeStamp else {return}
        let calendar = NSCalendar.currentCalendar()
        let startDay = calendar.startOfDayForDate(date)
        var messages = sections[startDay]
        if messages == nil{
            dates.append(startDay)
            messages = [Message]()
        }
        messages!.append(message)
        sections[startDay] = messages
    }
    
    func pressedSend(button: UIButton){
        guard let text = newMessageField.text where text.characters.count > 0 else {return}
        let message = Message()
        message.text = text
        message.timeStamp = NSDate()
        message.incoming = false
        addMessage(message)
        newMessageField.text = ""
        tableView.reloadData()
        tableView.scrollToBottom()
        view.endEditing(true)
        

    }
    func handleSingleTap(recognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    
    func initMockData(){
        var date = NSDate(timeIntervalSince1970: 1100000000)
        var localIncoming = true
        for i in 0...10{
            let m = Message()
            m.text = String(i)
            m.text = m.text! +  "This is a longer message"
            m.timeStamp = date
            m.incoming = localIncoming
            localIncoming = !localIncoming
            addMessage(m)
            if i%2 == 0{
                date = NSDate(timeInterval: 60 * 60 * 24, sinceDate: date)
            }
        }
    }

}



extension ChatViewController: UITableViewDataSource{
    func getMessages(section: Int) ->  [Message]{
        let date = dates[section]
        return sections[date]!
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dates.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMessages(section).count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ChatCell
        let messages = getMessages(indexPath.section)
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text
        cell.incoming(message.incoming)
        cell.backgroundColor = UIColor.clearColor()
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        return cell
        
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        let paddingView = UIView()
        view.addSubview(paddingView)
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        let dateLabel = UILabel()
        paddingView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            paddingView.centerXAnchor
                .constraintEqualToAnchor(view.centerXAnchor),
            paddingView.centerYAnchor
                .constraintEqualToAnchor(view.centerYAnchor),
            dateLabel.centerXAnchor
                .constraintEqualToAnchor(paddingView.centerXAnchor),
            dateLabel.centerYAnchor
                .constraintEqualToAnchor(paddingView.centerYAnchor),
            paddingView.heightAnchor
                .constraintEqualToAnchor(dateLabel.heightAnchor, constant: 5),
            paddingView.widthAnchor
                .constraintEqualToAnchor(dateLabel.widthAnchor, constant: 10),
            view.heightAnchor
                .constraintEqualToAnchor(paddingView.heightAnchor)
        ]
        NSLayoutConstraint.activateConstraints(constraints)
        let formater = NSDateFormatter()
        formater.dateFormat = "MMM dd, YYYY"
        dateLabel.text = formater.stringFromDate(dates[section])
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        return view
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

extension ChatViewController : UITableViewDelegate{
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

}