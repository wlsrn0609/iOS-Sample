//
//  ViewController.swift
//  BlurTest
//
//  Created by 권진구 on 2017. 4. 24..
//  Copyright © 2017년 권진구. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

class ViewController: UIViewController
,UIScrollViewDelegate
{

    var maskView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(makeBackView())
        
        let blurImage = self.blurWithImageEffects(image: self.takeSnapshotOfView(view: makeBackView()))
        let blurImageView = UIImageView(frame: self.view.frame)
        blurImageView.image = blurImage
        self.view.addSubview(blurImageView)
        
        let scrollView = UIScrollView(frame: self.view.frame)
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: (SCREEN_HEIGHT * 2) - 100)
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        self.maskView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 100, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        maskView.backgroundColor = UIColor.white
        blurImageView.layer.mask = maskView.layer
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        self.maskView.frame = CGRect(x: 0, y: self.view.frame.size.height - 100 - scrollView.contentOffset.y, width: self.maskView.frame.size.width, height: self.maskView.frame.size.height)
    }

    func takeSnapshotOfView(view : UIView) -> UIImage {
        
        let reductionFactor : CGFloat = 1
        
        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width / reductionFactor, height: view.frame.size.height / reductionFactor))
        view.drawHierarchy(in: CGRect(x: 0, y: 0, width: view.frame.size.width / reductionFactor, height: view.frame.size.height / reductionFactor), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image!
    }
    
    
    
    func makeBackView() -> UIView {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        
        let sampleImage = UIImage(named: "demo-bg")
        let sampleImageView = UIImageView(image: sampleImage!)
        sampleImageView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        backView.addSubview(sampleImageView)
        
        return backView
        
        
    }

    
    //MARK:way1
    func blurWithImageEffects(image : UIImage) -> UIImage {
        return image.applyBlur(withRadius: 30, tintColor: UIColor.white.withAlphaComponent(0.2), saturationDeltaFactor: 1.5, maskImage: nil)
    }
    
    
    //MARK:way2
    func blurWithCoreImage(souceImage : UIImage) -> UIImage {
        let inputImage = CIImage(cgImage: souceImage.cgImage!)
        
        let transform = CGAffineTransform.identity
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter?.setValue(inputImage, forKey: "inputImage")
        
        let value = NSValue.init(cgAffineTransform: transform)
        clampFilter?.setValue(value, forKey: "inputTransform")
        
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter?.setValue(clampFilter?.outputImage, forKey: "inputImage")
        gaussianBlurFilter?.setValue(NSNumber(value: 30), forKey: "inputRadius")
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage((gaussianBlurFilter?.outputImage)!, from: inputImage.extent)
    
        UIGraphicsBeginImageContext(self.view.frame.size)
        let outputContext = UIGraphicsGetCurrentContext()
        outputContext?.scaleBy(x: 1, y: -1)
        outputContext?.translateBy(x: 0, y: -self.view.frame.size.height)
        
        outputContext?.draw(cgImage!, in: self.view.frame)
        
        outputContext?.saveGState()
        outputContext?.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        outputContext?.fill(self.view.frame)
        outputContext?.restoreGState()
    
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage!
    }
    
    /*
    
    
    
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
    }
 */
}

