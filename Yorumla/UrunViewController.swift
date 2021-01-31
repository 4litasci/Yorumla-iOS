//
//  UrunViewController.swift
//  Yorumla
//
//  Created by Ali on 14/05/2017.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit
class yorumSonucCell:UITableViewCell{
   
    @IBOutlet weak var yorumlayan: UILabel!

    @IBOutlet weak var yorum: UILabel!
}


class UrunViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var urunResmi: UIImageView!
    @IBOutlet var urunAdi: UILabel!
    @IBOutlet weak var yorumLabel: UILabel!
    @IBOutlet var tableYorumlar: UITableView!
    var urunkodu:String = ""
    var gelenAd:String = ""
    var gelenResim:String = ""
    var list:[MyStruct] = [MyStruct]()
    var sonuc=""
    
    struct MyStruct
    {
        var yorumlayan = ""
        var yorum = ""
        var puan=""
        var tarih=""
        
        init(_ yorumlayan:String, _ yorum:String,_ puan:String,_ tarih:String)
        {
            self.yorumlayan = yorumlayan
            self.yorum = yorum
            self.puan=puan
            self.tarih=tarih
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        urunAdi.text=gelenAd
        tableYorumlar.dataSource = self
        tableYorumlar.delegate = self
        
        tableYorumlar.rowHeight=UITableViewAutomaticDimension
        tableYorumlar.estimatedRowHeight=80
        
     
        
        list.removeAll()
        get_data("https://yorumla.info/iosyorum.aspx?ara=",arama: urunkodu)

        let url = URL(string: gelenResim)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                //cell.imageView?.image = UIImage(data: data!)
                self.urunResmi.image=UIImage(data: data!)
                
                
            }
                    // Do any additional setup after loading the view.
    }

    }
    func get_data(_ link:String,arama:String)
    {
        let arama=arama.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let url:URL = URL(string: link+arama!)!
        let session = URLSession.shared
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            self.extract_data(data)
            
        })
        
        task.resume()
    }
    func extract_data(_ data:Data?)
    {
        let json:Any?
        
        if(data == nil)
        {
            return
        }
        
        do{
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        }
        catch
        {
            return
        }
        
        guard let data_array = json as? NSArray else
        {
            return
        }
        
        
        for i in 0 ..< data_array.count
        {
            if let data_object = data_array[i] as? NSDictionary
            {
                if let yorumlayan = data_object["yorumlayan"] as? String
                    ,let yorum = data_object["yorum"] as? String
                    ,let puan=data_object["puan"] as? String
                    ,let tarih=data_object["tarih"] as? String
                {
                    list.append(MyStruct(yorumlayan, yorum,puan,tarih))
                }
                
            }
        }
        if 0<data_array.count {
            sonuc=String(data_array.count)+" yorum bulundu."
        } else {
            sonuc="Yorum Bulunamadı."
        }

        
        refresh_now()
        
        
    }
    func refresh_now()
    {
        DispatchQueue.main.async(
            execute:
            {
                self.tableYorumlar.reloadData()
                self.yorumLabel.text=self.sonuc
                
                
        })
        
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! yorumSonucCell
        
        
       
            
        cell.yorum.text=list[indexPath.row].yorum
        cell.yorumlayan.text=list[indexPath.row].yorumlayan
        
        
        
        
        
        
        
        
        return cell
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="yorumiden" {
            let newVC:YorumController=segue.destination as! YorumController
            newVC.gelenad=gelenAd
            newVC.urunkodu=urunkodu
            let backItem = UIBarButtonItem()
            backItem.title = "Geri"
            navigationItem.backBarButtonItem = backItem
            
        }
        if segue.identifier=="detayiden"{
            let newVC:WebDetayViewController=segue.destination as! WebDetayViewController
            newVC.urunid=urunkodu
            let backItem = UIBarButtonItem()
            backItem.title = "Geri"
            navigationItem.backBarButtonItem = backItem
        }
        
        
        
    }
   


}
