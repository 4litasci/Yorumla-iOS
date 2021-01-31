//
//  AramaUrunModel.swift
//  Yorumla
//
//  Created by Ali on 19/03/2017.
//  Copyright © 2017 Ali. All rights reserved.
//

import Foundation
class AramaUrunModel: NSObject{
    var urunAdi:String?
    var urunID:String?
    var urunResim:String?
    
    override init()
    {
        
    }
    
    init(urunAdi:String,urunID:String,urunResim:String){
        self.urunAdi=urunAdi
        self.urunID=urunID
        self.urunResim=urunResim
    }
    
    override var description: String{
        return "UrunID: \(urunID) - UrunResim: \(urunResim) - UrunAdı: \(urunAdi)"
    }
}
