	//
//  YorumController.swift
//  Yorumla
//
//  Created by Ali on 12/06/2017.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit

class YorumController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var YorumYorum: UITextView!
    @IBOutlet weak var YorumPuan: UIPickerView!
    @IBOutlet weak var yorumAd: UITextField!
    @IBOutlet weak var urunadiLabel: UILabel!
    var puanlar=["Çok Kötü","Kötü","Orta","İyi","Çok İyi"]
    @IBOutlet weak var yorumButton: UIButton!
    var gelenad=""
    var urunkodu=""
    var puan=3
    override func viewDidLoad() {
        super.viewDidLoad()
        urunadiLabel.text=gelenad
        YorumPuan.delegate=self
        YorumPuan.dataSource=self
        YorumPuan.selectRow(2, inComponent: 0, animated: true)
        
    }
    @IBAction func yorumGonder(_ sender: Any) {
        let yorAd=yorumAd.text
        let yorPuan=String(puan)
        let yorYorum=YorumYorum.text
        let yorUrunID=urunkodu
        
        var request = URLRequest(url: URL(string: "https://yorumla.info/androidyorumgonder.aspx")!)
        request.httpMethod = "POST"
        let postString = "YorumIsim="+yorAd!+"&YorumYorum="+yorYorum!+"&YorumPuan="+yorPuan+"&YorumYorumlanan="+yorUrunID
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
        
        showToast(message: "Yorumunuz Gönderilmiştir. Teşekkürler.")
        yorumButton.isHidden=true
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return puanlar.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return puanlar[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        puan = row+1
    }
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 325, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
