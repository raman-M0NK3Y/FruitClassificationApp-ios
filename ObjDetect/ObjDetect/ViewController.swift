//
//  ViewController.swift
//  ObjDetect
//
//  Created by Raman Kullar on 2020-11-02.
//  Copyright © 2020 Raman Kullar. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    var model = fruitImgClass1().model

    @IBOutlet weak var bView: UIView!
    @IBOutlet weak var objTypeLab: UILabel!
    @IBOutlet weak var accLab: UILabel!
    
   
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // activte camera
        let captureSession = AVCaptureSession()
               
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return }
        captureSession.addInput(input) //rear camera
               
        captureSession.startRunning()
               
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
               
        view.addSubview(bView)
        bView.clipsToBounds = true
        bView.layer.cornerRadius = 15.0
        bView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
               
               
        let  dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
               
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
           guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
           
           guard let model = try? VNCoreMLModel(for: model) else { return }
           let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
               
               guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
               guard let firstObservation = results.first else {return}
               
               var name: String = firstObservation.identifier
               var acc: Int = Int(firstObservation.confidence * 100)
               
               DispatchQueue.main.async {
                   self.objTypeLab.text = name
                   self.accLab.text = "Accuracy: \(acc)%"
               }
               
           }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            
        }


}

