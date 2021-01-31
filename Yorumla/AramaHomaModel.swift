//
//  AramaHomaModel.swift
//  Yorumla
//
//  Created by Ali on 19/03/2017.
//  Copyright © 2017 Ali. All rights reserved.
//

import Foundation

protocol AramaHomaModelProtocol {
    func itemsDownloaded(items: NSArray)
}

class AramaHomaModel: NSObject,URLSessionDataDelegate{
    
    var delegate:AramaHomaModelProtocol!
    var data: NSMutableData=NSMutableData()
    
    let urlPath:String="https://yorumla.info/androidtest.aspx"
    
    func dowloadItems(){
        /*let url:NSURL=NSURL(string: urlPath)!
        var session:URLSession!
        let configuration = URLSessionConfiguration.default
        
        var session=urlSession(configuration:configuration,delegate:self,delegateQueue:nil)
        
        let task=session.dataTask(with: url as URL)
    
        task.resume()
    */
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data.append(data as Data);
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            self.parseJSON()
        }
        
    }
    func parseJSON() {
        
        var jsonResult: NSMutableArray = NSMutableArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: self.data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSMutableArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        let urunler: NSMutableArray = NSMutableArray()
        
        for i in 0 ..< jsonResult.count{
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let urun = AramaUrunModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let urunID = jsonElement["id"] as? String,
                let urunAdi = jsonElement["isim"] as? String,
                let urunResim = jsonElement["Latitude"] as? String
            {
                
                urun.urunID = urunID
                urun.urunAdi = urunAdi
                urun.urunResim = urunResim
                
            }
            
            urunler.add(urun)
            
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.itemsDownloaded(items: urunler)
            
        })
    }
}
