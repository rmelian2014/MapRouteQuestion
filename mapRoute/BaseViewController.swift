//
//  BaseViewController.swift
//  mapRoute
//
//  Created by Reinier Melian Massip on 3/15/18.
//  Copyright © 2018 AJ. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	public func showLoading(withDelay delay: TimeInterval? = nil,message:String = NSLocalizedString("k_loading", comment: "")){
		let delayValue : TimeInterval = delay ?? 0.00
		DispatchQueue.global().async {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delayValue * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
				let activityData = ActivityData(message: message,type:NVActivityIndicatorType.ballRotateChase,displayTimeThreshold:0)
				NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
			}
		}
	}
	
	public func hideLoading(withDelay delay: TimeInterval? = nil){
		let delayValue : TimeInterval = delay ?? 0.00
		DispatchQueue.global().async {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delayValue * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
				NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
			}
		}
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
