//
//  ViewController.swift
//  MLImageRecognitionBox
//
//  Created by Burak Kaymak on 9.09.2025.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationBarDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    var chosenImage = CIImage()
    var detectionOverlay : CALayer! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOverlay()
    }
    
    func setupOverlay(){
        
        //şeffaf bir katman eklediğimizi düşünebiliriz. bu katmanın üzerinde çerçeve ve yazılar olacak denebilir.
        
        detectionOverlay = CALayer() // şeffaf katman
        detectionOverlay.frame = imageView.bounds // layer boyutu tam imageview boyutunda olsun diyoruz. böylece kutucuklar doğru yere oturur,kaymaz.
        imageView.layer.addSublayer(detectionOverlay) // resim arka planda, oluşan layer üstte oluyor.
    }
    
    
    @IBAction func selectImageClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
        
        // Önceki kutuları temizle
        detectionOverlay.sublayers = nil
        
        analyzImage(image: chosenImage)
        
 
    }
    
    func analyzImage(image : CIImage){
        
        // 1)Request
        // 2)Handler
        
        if let model = try? VNCoreMLModel(for: YOLOv3().model) 
        {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                
                if let results = vnrequest.results as? [VNRecognizedObjectObservation]
                {
                    if results.count > 0 
                    {
                        DispatchQueue.main.async {
                            for observation in results {
                                self.drawBox(observation: observation)
                            }
                            
                        }
                    }
                }
            }
            
            //Handler
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                try handler.perform([request])
                }  catch {
                    print("error")
                }
                
                
                
        }

            
            
            
        }
        
    }
    
    func convertBoundingBox(_ boundingBox: CGRect, to imageView: UIImageView) -> CGRect {
        guard let image = imageView.image else { return .zero }
        
        let imageSize = image.size
        let viewSize = imageView.bounds.size
        
        // Görüntünün oranı
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        let scale = min(scaleX, scaleY)
        
        // Ortada boşluk (letterboxing) varsa onu bul
        let imageWidth = imageSize.width * scale
        let imageHeight = imageSize.height * scale
        let xOffset = (viewSize.width - imageWidth) / 2
        let yOffset = (viewSize.height - imageHeight) / 2
        
        // Vision koordinatlarını UIKit koordinatlarına çevir
        var rect = boundingBox
        rect.origin.x *= imageWidth
        rect.origin.y *= imageHeight
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        rect.origin.x += xOffset
        rect.origin.y = viewSize.height - rect.origin.y - rect.size.height - yOffset
        
        return rect
    }
    
    func drawBox(observation : VNRecognizedObjectObservation ){
        
        let box = observation.boundingBox
        let convertedRect = convertBoundingBox(observation.boundingBox, to: imageView)
        
        //KUTU
        let outline = CALayer()
        outline.frame = convertedRect
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.green.cgColor
        
        
        //LABEL
        if let topLabel = observation.labels.first 
        {
            let textLayer = CATextLayer()
            let confidenceLevel = (topLabel.confidence) * 100
            let rounded = Int(confidenceLevel * 100) / 100
            
            textLayer.string = "\(rounded)% it is \(topLabel.identifier)"
            textLayer.foregroundColor = UIColor.green.cgColor
            textLayer.fontSize = 14
            textLayer.frame = CGRect(x: convertedRect.origin.x, y: convertedRect.origin.y - 20, width: 200, height: 20)
            detectionOverlay.addSublayer(textLayer)
        }
        
        detectionOverlay.addSublayer(outline)
        
    }
        
    
    

}

