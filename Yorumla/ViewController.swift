//
//  ViewController.swift
//  Yorumla
//
//  Created by Ali on 19/03/2017.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit
import AVFoundation

class aramaSonucCell:UITableViewCell{
    @IBOutlet weak var tabloisim: UILabel!
    @IBOutlet weak var tabloresim: UIImageView!


}
class CameraView:UIView{
    override class var layerClass:AnyClass{
        get{
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    override var layer:AVCaptureVideoPreviewLayer{
        get{
            return super.layer as! AVCaptureVideoPreviewLayer
        }
    }
    
}

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,AVCaptureMetadataOutputObjectsDelegate  {
    @IBOutlet var table: UITableView!
    @IBOutlet var aramaText: UITextField!
    @IBOutlet var kapatButton: UIButton!
    @IBOutlet var kameraView: UIView!
    @IBOutlet weak var aramaLabel: UILabel!
    
    var sonuc=""
    var cameraView:CameraView!
    var videoDevice:AVCaptureDevice?=nil
    var videoDeviceInput:AVCaptureDeviceInput?=nil
    let session=AVCaptureSession()
    let sessionQueue=DispatchQueue(label:AVCaptureSession.self.description(), attributes:[],target:nil)

    
    
    var list:[MyStruct] = [MyStruct]()
    
    struct MyStruct
    {
        var name = ""
        var resim = ""
        var id=""
        
        init(_ name:String, _ resim:String,_ id:String)
        {
            self.name = name
            self.resim = resim
            self.id=id
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        table.dataSource = self
        table.delegate = self
        kapatButton.isHidden=true
        
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Update camera orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        default:
            videoOrientation = .portrait
        }
        cameraView.layer.connection.videoOrientation = videoOrientation
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Display barcode value
        if (metadataObjects.count > 0 && metadataObjects.first is AVMetadataMachineReadableCodeObject) {
            let scan = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            let alertController = UIAlertController(title: "Barkod doğru mu?", message: scan.stringValue, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Evet", style: .default, handler:{(handler) in self.barkodAra(aramaBarkod: scan.stringValue)}))
            alertController.addAction(UIAlertAction(title: "Hayır", style: .default, handler:nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func taraBas(_ sender: Any) {
        cameraView=CameraView()
        //view=cameraView
        view.bringSubview(toFront: kameraView)
        view.bringSubview(toFront: kapatButton)
        kameraView.isHidden=false
        kapatButton.isHidden=false
        session.beginConfiguration()
        
        videoDevice=AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if videoDevice != nil {
            videoDeviceInput=try? AVCaptureDeviceInput(device: videoDevice)
            
            if videoDeviceInput != nil {
                if(session.canAddInput(videoDeviceInput)){
                    session.addInput(videoDeviceInput)
                }
            }
            let metadataOutput = AVCaptureMetadataOutput()
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = [
                    AVMetadataObjectTypeEAN13Code,
                    AVMetadataObjectTypeQRCode
                ]
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
        }
        session.commitConfiguration()
        cameraView.layer.session = session
        cameraView.layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        kameraView.layer.addSublayer(cameraView.layer)
        cameraView.layer.position=CGPoint(x:self.kameraView.frame.width/2,y:self.kameraView.frame.height/2)
        cameraView.layer.bounds=kameraView.frame
        // Set initial camera orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeLeft
        case .landscapeRight:
            videoOrientation = .landscapeRight
        default:
            videoOrientation = .portrait
        }
        cameraView.layer.connection.videoOrientation = videoOrientation
        
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    @IBAction func araClick(_ sender: Any) {
        list.removeAll()
        get_data("https://yorumla.info/iosarama.aspx?ara=",arama: aramaText.text!)
        view.endEditing(true)
    }
    
    func barkodAra(aramaBarkod:String) {
        list.removeAll()
        sessionQueue.async {
            self.session.stopRunning()
        }
        kameraView.isHidden=true
        kapatButton.isHidden=true

        
        get_data("https://yorumla.info/iosarama.aspx?ara=",arama: aramaBarkod)
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
                if let isim = data_object["ad"] as? String
                    ,let resim = data_object["img"] as? String
                    ,let urunkod=data_object["id"] as? String
                {
                    list.append(MyStruct(isim, resim,urunkod))
                }
                
            }
        }
        if 0<data_array.count {
            sonuc=String(data_array.count)+" ürün bulundu."
        } else {
            sonuc="Ürün Bulunamadı."
        }
        refresh_now()
        
        
    }
    func refresh_now()
    {
        DispatchQueue.main.async(
            execute:
            {
                self.table.reloadData()
                self.aramaLabel.text=self.sonuc
                
        })
        
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! aramaSonucCell
        
        
        let url = URL(string: list[indexPath.row].resim)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                //cell.imageView?.image = UIImage(data: data!)
                cell.tabloresim.image=UIImage(data: data!)
                
                
            }
        
        }
        //cell.textLabel?.text = list[indexPath.row].name
        cell.tabloisim.text=list[indexPath.row].name
        
        
        
        /*let url = URL(string: list[indexPath.row].resim)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.imageView?.image = UIImage(data: data!)*/
        
        
        
        
        
        
        return cell
    }
    
    
    
   /* override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/

    @IBAction func kapatButtonAction(_ sender: Any) {
        sessionQueue.async {
            self.session.stopRunning()
        }
        kameraView.isHidden=true
        kapatButton.isHidden=true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newVC:UrunViewController=segue.destination as! UrunViewController
        let selected=table.indexPathForSelectedRow
        let resim=list[(selected?.row)!].resim
        newVC.urunkodu=list[(selected?.row)!].id
        newVC.gelenAd=list[(selected?.row)!].name
        newVC.gelenResim=resim.replacingOccurrences(of: "_kucuk", with: "_buyuk")
        let backItem = UIBarButtonItem()
        backItem.title = "Geri"
        navigationItem.backBarButtonItem = backItem
        
        
        
    }

}

/*
 
 import UIKit
 
 class ViewController: UIViewController {
 
 @IBOutlet weak var listTableView: UITableView!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 // Do any additional setup after loading the view, typically from a nib.
 }
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 
 }
 
 */
