//
//  ViewController.swift
//  Wuziqi
//
//  Created by guojianfeng on 2017/8/17.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy fileprivate var boardView: CheckerboardView = CheckerboardView(frame: CGRect.init(x: 20, y: 30, width: self.view.frame.width, height: self.view.frame.width))
    lazy fileprivate var changeBoardButton = UIButton(type: .custom)
    lazy fileprivate var backButton = UIButton(type: .custom)
    lazy fileprivate var reStartBtn = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    func configUI()  {
        view.backgroundColor = UIColor.lightGray
        boardView.center = view.center
        view.addSubview(boardView)
        
        //悔棋
        changeBoardButton.setTitle("初级棋盘", for: .normal)
        changeBoardButton.setTitleColor(UIColor.gray, for: .disabled)
        changeBoardButton.backgroundColor = UIColor(red: 200 / 255.0, green: 160 / 255.0, blue: 130 / 255.0, alpha: 1)
        changeBoardButton.frame = CGRect(x: boardView.frame.midX - boardView.frame.width * 0.3, y: boardView.frame.minY - 50, width: boardView.frame.width * 0.6, height: 35)
        changeBoardButton.layer.cornerRadius = 4
        view.addSubview(changeBoardButton)
        changeBoardButton.addTarget(boardView, action: #selector(CheckerboardView.changeBoard), for: .touchUpInside)
        
        //悔棋
        backButton.setTitle("悔棋", for: .normal)
        backButton.setTitleColor(UIColor.gray, for: .disabled)
        backButton.backgroundColor = UIColor(red: 200 / 255.0, green: 160 / 255.0, blue: 130 / 255.0, alpha: 1)
        backButton.frame = CGRect(x: boardView.frame.minX, y: boardView.frame.maxY + 15, width: boardView.frame.width * 0.45, height: 30)
        backButton.layer.cornerRadius = 4
        view.addSubview(backButton)
        backButton.addTarget(boardView, action: #selector(CheckerboardView.backOneStep), for: .touchUpInside)
        
        //新游戏
        reStartBtn.setTitle("新游戏", for: .normal)
        reStartBtn.backgroundColor = UIColor(red: 200 / 255.0, green: 160 / 255.0, blue: 130 / 255.0, alpha: 1)
        reStartBtn.frame = CGRect(x: boardView.frame.maxX - boardView.frame.width * 0.45, y: boardView.frame.maxY + 15, width: boardView.frame.width * 0.45, height: 30)
        reStartBtn.layer.cornerRadius = 4
        view.addSubview(reStartBtn)
        reStartBtn.addTarget(boardView, action: #selector(CheckerboardView.newGame), for: .touchUpInside)
    }
}

//MARK: Action
extension ViewController{
    
}

