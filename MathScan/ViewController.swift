//
//  ViewController.swift
//  MathScan
//
//  Created by Benedikt Veith on 10.10.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit
import AVFoundation
import TesseractOCR

protocol ViewControllerDelegate: class {
    func updateHeaderAndView(index: Int, progress: CGFloat);
    func updateScrollHeader(currentIndex: Int, index: Int, progress: CGFloat);
}

class ViewController: UIViewController, G8TesseractDelegate, AVCapturePhotoCaptureDelegate, MenuPageViewControllerDelegate, TransparentViewDelegate {
    weak var customDelegate: ViewControllerDelegate!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var scanAreaView: UIView!
    @IBOutlet weak var equationView: UIView!
    @IBOutlet weak var equationLabel: UILabel!
    @IBOutlet weak var solutionView: UIView!
    @IBOutlet weak var solutionLabel: UILabel!
    @IBOutlet weak var solutionEqualLabel: UILabel!
    @IBOutlet weak var coverLayerView: UIView!
    
    @IBOutlet weak var transparentView: TransparentView!
    
    var captureSession: AVCaptureSession = AVCaptureSession();
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var tesseract: G8Tesseract?
    var cameraTimer: Timer!
    var tesseractChoices: [NSArray]!
    
    var blockViewInteraction: Bool = false;
    var menuPageViewController: MenuPageViewController?;
    
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.transparentView.delegate = self;
        
        self.tesseract = G8Tesseract(language:"eng");
        self.tesseract?.delegate = self;
        self.tesseract?.maximumRecognitionTime = 1.5;
        
        let dottedBorder = CAShapeLayer();
        dottedBorder.strokeColor = UIColor.white.cgColor;
        dottedBorder.fillColor = nil;
        dottedBorder.lineDashPattern = [4, 4];
        dottedBorder.path = UIBezierPath(roundedRect: scanAreaView.bounds, cornerRadius: 0).cgPath;
        dottedBorder.frame = scanAreaView.bounds;
        scanAreaView.layer.addSublayer(dottedBorder);
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (finished) in };
        
        self.capturePhotoOutput = AVCapturePhotoOutput();
        self.capturePhotoOutput?.isHighResolutionCaptureEnabled = true;
        self.captureSession.addOutput(self.capturePhotoOutput!);
        
        do {
            self.captureSession.addInput(try AVCaptureDeviceInput(device: self.captureDevice!));
        } catch {
            print("AVCaptureDeviceInput Error")
        }
        
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame.origin = CGPoint.zero
        self.videoPreviewLayer?.frame.size = self.cameraView.frame.size
        
        do {
            try self.captureDevice?.lockForConfiguration()
            self.captureDevice?.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            self.captureDevice?.focusMode = .continuousAutoFocus
            self.captureDevice?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
        
        DispatchQueue.main.async(execute: {
            self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
            self.captureSession.startRunning()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.cameraTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(scanCamera), userInfo: nil, repeats: true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.cameraTimer?.invalidate();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedSegue") {
            let vc = segue.destination as! MenuPageViewController;
            vc.customDelegate = self;
            
            self.menuPageViewController = vc;
        }
    }
    
    func scrollToPage(index: Int) {
        self.menuPageViewController?.scrollToPage(index: index);
    }
    
    func updateHeaderAndView(index: Int, progress: CGFloat) {
        self.cameraTimer?.invalidate();
        
        self.customDelegate.updateHeaderAndView(index: index, progress: progress);
        
        if index == 1 && progress == 1 {
            self.coverLayerView.backgroundColor = UIColor.clear;
            return;
        }
        
        var progress = progress;
        if index == 1 {
            progress = 1 - progress;
        } else {
            progress = 0 + progress;
        }
        
        self.coverLayerView.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: progress);
    }
    
    func updateScrollHeader(currentIndex: Int, index: Int, progress: CGFloat) {
        self.customDelegate.updateScrollHeader(currentIndex: currentIndex, index: index, progress: progress);
    }
    
    func transitionDone(index: Int) {
        if index == 1 {
            self.blockViewInteraction = false;
            return;
        }
        
        self.blockViewInteraction = true;
    }
    
    func point(inside point: CGPoint, with event: UIEvent?) {
        if self.blockViewInteraction == false {
            for subview in self.view.subviews {
                if subview is UIButton {
                    let button : UIButton = subview as! UIButton
                    
                    if (button.point(inside: button.convert(point, from: self.transparentView), with: event)) {
                        button.sendActions(for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    // MARK: CAPTURE IMAGE AND RUN OCR ON IT

    /// Takes a picture of the screen every second
    @objc func scanCamera() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self);
    }
    
    /// Processes Image Data & Runs OCR on it
    /// Validates, Calculates, Format Text
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(String(describing: error))");
            return;
        }
        
        // Convert photo to jpeg image data
        guard let imageData = photo.fileDataRepresentation() else {
            return;
        }
        
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        let tenthHeight = (capturedImage?.size.height)! * (self.scanAreaView.frame.height / self.view.frame.height);
        let openCVWrapper = OpenCVWrapper();
        
        self.tesseract?.image = openCVWrapper.preprocessImage(capturedImage?.g8_blackAndWhite());
        
        // Only OCR Scan Area of Image
        self.tesseract?.rect = CGRect(x: (capturedImage?.size.width)! / 8, y: (capturedImage?.size.height)! / 2 - tenthHeight / 2, width: (capturedImage?.size.width)! - ((capturedImage?.size.width)! / 8), height: tenthHeight)
        self.tesseract?.recognize();
        self.tesseract?.engineMode = G8OCREngineMode.tesseractOnly;
        self.tesseract?.charWhitelist = "abcdefghijklmnopqrstuvwxyz1234567890=+-.,";
        
        var recognizedText = self.tesseract!.recognizedText!;
        guard recognizedText.count > 0 else {
            return;
        }
        
        do {
            try self.tesseractChoices = self.tesseract?.characterChoices as! [NSArray];
        } catch {
            return;
        }
        
        
        let validationHelper = ValidationHelper();
        let validationResult = validationHelper.validateText(recognizedText: recognizedText, recognizedCharacter: self.tesseractChoices);
        
        guard validationResult["valid"] as! Bool == true else {
            return;
        }
        
        recognizedText = validationResult["text"] as! String;
        
        let calculator = MathCalculator();
        let calculationResult = calculator.solveEquation(text: recognizedText);
        
        recognizedText = calculationResult["text"] as! String;
        
        let formatter = FormatHelper();
        let formattedResult = formatter.formatAndBeautifySolution(solution: recognizedText);
        
        self.solutionView.isHidden = false;
        self.equationView.isHidden = false;
        self.solutionEqualLabel.isHidden = true;
        
        self.equationLabel.text = validationResult["text"] as? String;
        self.solutionLabel.text = formattedResult;
        
        guard calculationResult["isEqual"] == nil else {
            self.solutionEqualLabel.isHidden = false;
            
            if calculationResult["isEqual"] as! Bool == true {
                self.solutionEqualLabel.text = "TRUE";
            }
            
            self.solutionEqualLabel.text = "FALSE";
            return;
        }
    }
}

