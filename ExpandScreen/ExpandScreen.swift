//
//  ExpandScreen.swift
//  ExpandScreen
//
//  Created by nullLuli on 2019/3/5.
//  Copyright © 2019 nullLuli. All rights reserved.
//

import Foundation
import UIKit

protocol IExpandScreen: class {
    var expandScreenView: UIScrollView {get set}
    var lastDirection: Direction {get set}
    var isAnimate: Bool {get set}
    var offsetThresholdWhenUp: CGFloat {get}
    var offsetThresholdWhenDown: CGFloat {get}
    
    //供可滚动内容调用
    func scrollableContentScroll(_ direction: Int, _ offsetY: CGFloat,_ lastDirection: UnsafeMutablePointer<Int>) -> Bool
    func pageTurnExpand()
    
    //功能方法
    func changeOffset(_ diffOffsetY: CGFloat)
    func pageTurn()
    func upTurn()
    func downTurn()
}

extension IExpandScreen {
    func scrollableContentScroll(_ direction: Int, _ offsetY: CGFloat,_ lastDirection: UnsafeMutablePointer<Int>) -> Bool {
        guard !isAnimate else { return true }
        
        let direcionL = Direction(rawValue: direction)
        
        if direcionL == .up {
            if offsetY < 0 {return false } //不知道为什么，是会出现这种判断方向是向上，但是offset < 0 的情况
            self.lastDirection = .up
            lastDirection.pointee = self.lastDirection.rawValue
            if expandScreenView.contentOffset.y < offsetThresholdWhenUp {
                let restY = offsetThresholdWhenUp - expandScreenView.contentOffset.y
                let moveViewsDiffY = min(restY, offsetY)
                changeOffset(moveViewsDiffY)
                return true
            }
        } else if direcionL == .down {
            if offsetY > 0 { return false }
            self.lastDirection = .down
            lastDirection.pointee = self.lastDirection.rawValue
            if expandScreenView.contentOffset.y > offsetThresholdWhenDown {
                let restY = offsetThresholdWhenDown - expandScreenView.contentOffset.y
                let moveViewsDiffY = max(restY, offsetY)
                changeOffset(moveViewsDiffY)
                return true
            }
        }
        return false
    }
    
    func pageTurnExpand() {
        pageTurn()
    }
    
    func changeOffset(_ diffOffsetY: CGFloat) {
        expandScreenView.contentOffset.y += diffOffsetY
    }
    
    func pageTurn() {
        if lastDirection == .down {
            downTurn()
        } else if lastDirection == .up {
            upTurn()
        }
    }
    
    func upTurn() {
        let restY = offsetThresholdWhenUp - expandScreenView.contentOffset.y
        isAnimate = true
        UIView.animate(withDuration: 0.25, animations: {
            self.changeOffset(restY)
        }) { (complete) in
            self.isAnimate = false
        }
    }
    
    func downTurn() {
        let restY = offsetThresholdWhenDown - expandScreenView.contentOffset.y
        isAnimate = true
        UIView.animate(withDuration: 0.25, animations: {
            self.changeOffset(restY)
        }) { (complete) in
            self.isAnimate = false
        }
    }
}

protocol IExpandScrollableContent: class {
    var expandScreen: IExpandScreen? {get set}
    var lastOffsetY: CGFloat {get set}
    var lastDirection: Int {get set}
    
    func scrollViewDidScroll_ExpandScreen(_ contentScrollView: UIScrollView) -> Bool
    func scrollViewDidEndScroll_ExpandScreen(_ contentScrollView: UIScrollView)
}

extension IExpandScrollableContent {
    func scrollViewDidScroll_ExpandScreen(_ contentScrollView: UIScrollView) -> Bool {
        let direction = contentScrollView.panGestureRecognizer.direction?.rawValue ?? lastDirection
        let ifExpandDidScroll = expandScreen?.scrollableContentScroll(direction, contentScrollView.contentOffset.y - lastOffsetY, &lastDirection)
        let contentShouldScroll = !(ifExpandDidScroll ?? false)
        if !contentShouldScroll {
            contentScrollView.contentOffset.y = lastOffsetY
        }
        lastOffsetY = contentScrollView.contentOffset.y
        return contentShouldScroll
    }
    
    func scrollViewDidEndScroll_ExpandScreen(_ contentScrollView: UIScrollView) {
        expandScreen?.pageTurnExpand()
    }
}

enum Direction: Int {
    case up
    case down
    case left
    case right
}

extension UIPanGestureRecognizer {
    
    var direction: Direction? {
        let velocity = self.velocity(in: view)
        let vertical = abs(velocity.y) > abs(velocity.x)
        switch (vertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
        }
    }
}
