//
//  CheckerboardView.swift
//  Wuziqi
//
//  Created by guojianfeng on 2017/8/17.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

import UIKit

enum GmkDirection{
    case GmkHorizontal
    case GmkVertical
    case GmkObliqueDown
    case GmkObliqueUp
}

fileprivate let kGridCount: Int = 15 //格子数
fileprivate let kChessmanSizeRatio: CGFloat = 0.8 //棋子宽高占格子宽高的百分比,大于0,小于1
fileprivate let kBoardSpace: CGFloat = 20  //棋盘边界

class CheckerboardView: UIView {
    
    fileprivate var gridWidth: CGFloat = 0.0
    fileprivate var isBlack: Bool = true
    fileprivate var isHighLevel: Bool = false
    fileprivate var gridCount: Int {
        return isHighLevel ? kGridCount + 4 : kGridCount
    }
    fileprivate var chessmanDict: [String: Any] =  [String: Any]()
    fileprivate var sameChessmanArray: [UIView] =  [UIView]()
    fileprivate var lastKey: String?
    fileprivate var isOver: Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: public Method
extension CheckerboardView{
    func changeBoard(){
        for view: UIView in subviews {
            view.removeFromSuperview()
        }
        newGame()
        isHighLevel = !isHighLevel
        drawBackground(bounds.size)
    }
    
    func backOneStep(_ sender: UIButton){
        if self.isOver{ return }
        
        if (self.lastKey == nil) {
            sender.isEnabled = false
            let width: CGFloat = bounds.size.width * 0.4 * (bounds.size.width / 320);
            let tip: UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0.6 * width))
            tip.backgroundColor = UIColor(white: 1, alpha: 0.8)
            tip.layer.cornerRadius = 8.0;
            addSubview(tip)
            tip.center = CGPoint(x:width * 0.5, y:height * 0.5);
            tip.center.x = self.center.x
            let label: UILabel = UILabel()
            label.text = self.chessmanDict.count > 0 ? "只能悔一步棋!!!" : "请先落子!!!";
            label.font = UIFont.systemFont(ofSize: 15)
            label.sizeToFit()
            label.center = CGPoint(x:tip.width * 0.5, y:tip.height * 0.5);
            tip.addSubview(label)
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                self.isUserInteractionEnabled = true
                sender.isEnabled = true
                tip.removeFromSuperview()
            })
            return
        }
        chessmanDict.removeValue(forKey: lastKey!)
        subviews.last?.removeFromSuperview()
        self.isBlack = !self.isBlack;
        self.lastKey = nil;
        print("backOneStep")
    }
    
    func newGame(){
        isOver = false
        lastKey = nil
        sameChessmanArray.removeAll()
        isUserInteractionEnabled = true
        chessmanDict.removeAll()
        for view: UIView in subviews {
            if (view is UIImageView) {
                continue
            }
            view.removeFromSuperview()
        }
        isBlack = false
    }
}

//MARK: UIConfig
extension CheckerboardView{
    func configUI() {
        frame = CGRect.init(x: frame.origin.x, y: frame.origin.y, width: viewWidth(), height: viewWidth())
        self.backgroundColor = UIColor(colorLiteralRed: 200/255.0, green: 160/255.0, blue: 130/255.0, alpha: 1)//[UIColor colorWithRed,:200/255.0 green:160/255.0 blue:130/255.0 alpha:1];
        drawBackground(self.size)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBoard)))
    }
    
    func viewWidth() -> CGFloat {
        return frame.width > frame.height ? frame.height : frame.width
    }
    
    func drawBackground(_ size: CGSize) {
        self.gridWidth = (size.width - CGFloat(2 * kBoardSpace)) / CGFloat(gridCount)
        
        UIGraphicsBeginImageContext(size)
        
        let ctx: CGContext =  UIGraphicsGetCurrentContext()!
        ctx.setLineWidth(0.8)
        for i in 0..<gridCount+1 {
            ctx.move(to: CGPoint(x:  kBoardSpace + CGFloat(i) * self.gridWidth , y: kBoardSpace))
            ctx.addLine(to: CGPoint(x:  kBoardSpace + CGFloat(i) * self.gridWidth , y: kBoardSpace  + CGFloat(gridCount) * gridWidth))
            
            
            ctx.move(to: CGPoint(x:  kBoardSpace, y: kBoardSpace  + CGFloat(i) * gridWidth))
            ctx.addLine(to: CGPoint(x:  kBoardSpace + CGFloat(gridCount) * gridWidth, y: kBoardSpace + CGFloat(i) * self.gridWidth))
        }
        
        ctx.strokePath()
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        UIGraphicsEndImageContext()
    }
    
    func chessman() -> UIView {
        let chessmanView = UIView(frame: CGRect(x: 0, y: 0, width: gridWidth * kChessmanSizeRatio, height: gridWidth * kChessmanSizeRatio))
        chessmanView.layer.cornerRadius = chessmanView.width * 0.5
        chessmanView.backgroundColor = !isBlack ? UIColor.black : UIColor.white
        return chessmanView
    }
    
}

//MARK: Action
extension CheckerboardView{
    @objc fileprivate func tapBoard(_ tap: UITapGestureRecognizer){
        let point: CGPoint = tap.location(in: tap.view)
        let col: Int = Int((point.x - kBoardSpace + 0.5 * gridWidth) / gridWidth)
        let row: Int = Int((point.y - kBoardSpace + 0.5 * gridWidth) / gridWidth)
        let key: String = "\(col)-" + "\(row)"
        if !chessmanDict.keys.contains(key) {
            let chessView = chessman()
            chessView.center = CGPoint(x:kBoardSpace + CGFloat(col) * self.gridWidth, y:kBoardSpace + CGFloat(row) * self.gridWidth)
            addSubview(chessView)
            chessmanDict[key] = chessView
            lastKey = key
            checkResult(col, row)
            self.isBlack = !self.isBlack
        }
    }
}

//MARK: game check
extension CheckerboardView{
    fileprivate func checkResult(_ col: Int,_ row: Int) {
        checkResult(col, andRow: row, andColor: isBlack, andDirection: .GmkHorizontal)
        checkResult(col, andRow: row, andColor: isBlack, andDirection: .GmkVertical)
        checkResult(col, andRow: row, andColor: isBlack, andDirection: .GmkObliqueDown)
        checkResult(col, andRow: row, andColor: isBlack, andDirection: .GmkObliqueUp)
    }
    
    
    func checkResult(_ col: Int, andRow row: Int, andColor isBlack: Bool, andDirection direction: GmkDirection){
        if sameChessmanArray.count >= 5 {
            return
        }
        let currentChessman: UIView? = chessmanDict["\(col)-\(row)"] as? UIView
        let currentChessmanColor: UIColor? = currentChessman?.backgroundColor
        sameChessmanArray.append(chessmanDict[lastKey!] as! UIView)
        switch direction {
        //水平方向检查结果
        case .GmkHorizontal:
            for i in 0...((col-1 >= 0) ? col-1 : 0){
                let key: String = "\(i)-\(row)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
            }
            
            for i in ((col + 1) < gridCount ? (col + 1) : gridCount)...gridCount {
                let key: String = "\(i)-\(row)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
            }
            
            if (self.sameChessmanArray.count >= 5) {
                alertResult()
                return
            }
            sameChessmanArray.removeAll()
        case .GmkVertical:
            for i in 0...((col-1 >= 0) ? col-1 : 0) {
                let key: String = "\(col)-\(i)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
            }
            
            for i in ((col + 1) < gridCount ? (col + 1) : gridCount)...gridCount {
                let key: String = "\(col)-\(i)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
            }
            
            if (self.sameChessmanArray.count >= 5) {
                alertResult()
                return
            }
            sameChessmanArray.removeAll()
        case .GmkObliqueDown:
            var j: Int = col - 1
            var i = row - 1
            while i >= 0 {
                let key: String = "\(j)-\(i)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor || j < 0 {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
                i -= 1; j -= 1
            }

            j = col + 1
            i = row + 1
            while i < gridCount {
                let key: String = "\(j)-\(i)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor || j > gridCount {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
                i += 1; j += 1
            }
            
            if (self.sameChessmanArray.count >= 5) {
                alertResult()
                return
            }
            sameChessmanArray.removeAll()
        case .GmkObliqueUp:
            //向前遍历
            var j: Int = col + 1
            var i = row - 1
            while i >= 0 {
                let key: String = "\(j)-\(i)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor || j > gridCount {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
                i -= 1; j += 1
            }
            //向后遍历
            j = col - 1
            i = row + 1
            while i < gridCount {
                let key: String = "\(j)-\(i)"
                let chessman: UIView? = chessmanDict[key] as? UIView
                if !chessmanDict.keys.contains(key) || chessman?.backgroundColor != currentChessmanColor || j < 0 {
                    break
                }
                sameChessmanArray.append(chessmanDict[key] as! UIView)
                i += 1; j -= 1
            }
            if (self.sameChessmanArray.count >= 5) {
                alertResult()
                return
            }
            sameChessmanArray.removeAll()
        }
    }
    
    
    //游戏结果,提示效果
    func alertResult() {
        isOver = true
        let width: CGFloat = bounds.size.width * 0.4 * (bounds.size.width / 320)
        let tip = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0.6 * width))
        tip.backgroundColor = UIColor(white: 1, alpha: 0.8)
        tip.alpha = 1
        tip.layer.cornerRadius = 8.0
        addSubview(tip)
        tip.center = CGPoint(x: self.width * 0.5, y: height * 0.5)
        let label = UILabel()
        label.text = isBlack ? "白方胜" : "黑方胜"
        label.sizeToFit()
        label.center = CGPoint(x: tip.width * 0.5, y: tip.height * 0.5)
        tip.addSubview(label)
        let anim = CAKeyframeAnimation()
        anim.values = [(1), (0), (1)]
        anim.keyPath = "opacity"
        anim.duration = 0.8
        anim.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        for view: UIView in sameChessmanArray {
            view.layer.add(anim, forKey: "alpha")
        }
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            tip.removeFromSuperview()
        })
    }
}
