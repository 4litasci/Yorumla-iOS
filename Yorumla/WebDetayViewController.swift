//
//  WebDetayViewController.swift
//  Yorumla
//
//  Created by Ali on 14/05/2017.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

class WebDetayViewController: UIViewController {

    var urunid:String = ""
    @IBOutlet var webViewDetay: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "https://yorumla.info/androidurunbilgi.aspx?ID="+urunid) {
            let request = URLRequest(url: url)
            webViewDetay.loadRequest(request)
        }        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
