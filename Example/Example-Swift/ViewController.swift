//
//  ViewController.swift
//  Example-Swift
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import CSHud

class ViewController: UIViewController {
    
    typealias IMP = @convention(c)(Any, Selector, UIView, String?, [String]?) -> Void
    
    @IBOutlet weak var tbView: UITableView!
    
    let cellId = "cellId"
    lazy var data =
        [["showMessageInView:message:": "文本"],
         ["showSuccessAnimation": "成功(动画) >>"],
         ["showFailedAnimation": "失败(动画) >>"],
         
         ["showLoadingInView:": "菊花"],
         ["showLoadingInView:message:": "菊花 + 文本"],
         ["showLoadingUpDateInView:": "菊花 + 上次更新时间"],
         ["showBlurInView:message:": "菊花 + 文本 + 蒙版"],
         ["showRoundLoadingInView:message:": "环形加载动画"],
         ["showCustomAnimateInView:message:imageArray:duration:": "自定义加载动画"]
    ]
    
    lazy var icons: [String] = {
        var temp = [String]()
        for i in 0..<8 {
            temp.append("icon\(i)")
        }
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let data_cell = data[indexPath.row]
        guard let key = data_cell.keys.first else {
            return cell
        }
        cell.textLabel?.text = data_cell[key]
        if key == "showFailedAnimation" || key == "showSuccessAnimation" {
            cell.textLabel?.textColor = UIColor.blue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data_cell = data[indexPath.row]
        guard let key = data_cell.keys.first,
            let value = data_cell[key] else {
                return
        }
        let selParts = key.components(separatedBy: ":")
        let sel = Selector(key)
        if let ori_imp = HUD.method(for: sel), HUD.responds(to: sel) {
            let imp = unsafeBitCast(ori_imp, to: IMP.self)
            if selParts.count > 3 {
                imp(HUD.self, sel, view, value, icons)
            } else if selParts.count > 2 {
                imp(HUD.self, sel, view, value, nil)
            } else if selParts.count > 1 {
                imp(HUD.self, sel, view, nil, nil)
            }
        } else {
            guard let firstPart = selParts.first else {
                return
            }
            if firstPart == "showFailedAnimation" {
                showFailedHud(arr: selParts)
            } else if firstPart == "showSuccessAnimation" {
                showSuccessHud(arr: selParts)
            } else {
                HUD.showFailed(in: view, message: "无对应Action")
            }
        }
        
        if value.contains("成功") || value.contains("失败") || value == "文本" {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            HUD.hide(with: self.view)
        }
        
    }
    
    func showSuccessHud(arr: [String]) {
        print("--->\((#file as NSString).lastPathComponent)[\(#line)],\(#function)")
    }
    
    func showFailedHud(arr: [String]) {
        print("--->\((#file as NSString).lastPathComponent)[\(#line)],\(#function)")
    }
    
    
}

