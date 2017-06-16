//
//  ViewController.swift
//  SampleImage
//
//  Created by apple on 08/04/17.
//  Copyright © 2017 Improstech. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, G8TesseractDelegate
{
    @IBOutlet weak var Image1: UIImageView!
    @IBOutlet weak var Image2: UIImageView!
    @IBOutlet weak var Image3: UIImageView!
    @IBOutlet weak var compare: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageSize: UILabel!
    @IBOutlet weak var imageColor: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var colorDifference: UILabel!
    
    var picker: UIImagePickerController? = UIImagePickerController()
    var imagePicked = 0
    var imageColor1: UIColor = UIColor()
    var imageColor2: UIColor = UIColor()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedMe(gestureRecognizer:)))
        Image1.addGestureRecognizer(tap1)
        Image1.tag = 1
        Image1.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedMe(gestureRecognizer:)))
        Image2.addGestureRecognizer(tap2)
        Image2.tag = 2
        Image2.isUserInteractionEnabled = true
        
        picker?.delegate = self
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!)
    {
        print("Recognition Progress: \(tesseract.progress)%")
    }
    
    func tappedMe(gestureRecognizer: UITapGestureRecognizer)
    {
        imagePicked = (gestureRecognizer.view?.tag)!
        if imagePicked == 1
        {
            let tappedPoint: CGPoint = gestureRecognizer.location(in: self.view!)
            imageColor1 = getPixelColorAtPoint(point: tappedPoint)
        }
        else
        {
            let tappedPoint: CGPoint = gestureRecognizer.location(in: self.view!)
            imageColor2 = getPixelColorAtPoint(point: tappedPoint)
        }
        
        let alert: UIAlertController = UIAlertController(title: "Add Image", message: nil, preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            
        }
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallery()
        }
    }
    
    func openGallery()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(picker!, animated: true, completion: nil)
        }
        else
        {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            if imagePicked == 1
            {
                let img = image
                Image1.image = ResizeImage(image: img, targetSize: CGSize(width: 1024, height: 1024))
                print(Image1.image!.size)
                Image1.layer.borderWidth = 1.0
                Image1.layer.borderColor = UIColor.white.cgColor
            }
            else
            {
                let img = image
                Image2.image = ResizeImage(image: img, targetSize: CGSize(width: 1024, height: 1024))
                print(Image2.image!.size)
                Image2.layer.borderWidth = 1.0
                Image2.layer.borderColor = UIColor.white.cgColor
                
            }
        }
        else
        {
            print("Something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("Picker Cancel")
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage
    {
        _ = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio)
        {
            newSize = CGSize(width: targetSize.width, height: targetSize.height)
        }
        else
        {
            newSize = CGSize(width: targetSize.width, height: targetSize.height)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func compareButtonClicked(_ sender: UIButton)
    {
        if (Image1.image?.size.width != Image2.image?.size.width) || (Image1.image?.size.height != Image2.image?.size.height)
        {
            print("Two images are not identical in their size!!!")
            return
        }
        
        let bottomImage = Image1.image
        let topImage = Image2.image
        
        let size = CGSize(width: 2048, height: 2048)
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage!.draw(in: areaSize)
        topImage!.draw(in: areaSize, blendMode: .difference, alpha: 1)
        Image3.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageSize.text! = "Image Size: \((Image3.image?.size.width)!) x \((Image3.image?.size.height)!)"
        let colorDiff = imageColor1.getColorDifference(fromColor: imageColor2)
        colorDifference.text = "Color Difference: \(colorDiff)"
        
        if let tesseract = G8Tesseract(language: "eng")
        {
            tesseract.delegate = self
            tesseract.pageSegmentationMode = .auto
            tesseract.image = Image3.image?.g8_blackAndWhite()
            tesseract.recognize()
            textView.text = tesseract.recognizedText
            textView.isScrollEnabled = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch: UITouch = touches.first! as UITouch
        let loc = touch.location(in: self.Image3)
        let color:UIColor = getPixelColorAtPoint(point: loc)
        //let imgColor = hexFromUIColor(color: color)
        //imageColor.text = "Color: \(imgColor)"
        let imgColor = color.rgb()
        imageColor.text = "Color: \(imgColor!)"
        imageColor.textColor = color
        position.text = "Position: X: \((loc.x).rounded()), Y: \((loc.y).rounded())"
    }
    
    func hexFromUIColor(color: UIColor) -> String
    {
        let hexString = String(format: "%02X%02X%02X", Int((color.cgColor.components?[0])! * 255.0), Int((color.cgColor.components?[1])! * 255.0), Int((color.cgColor.components?[2])! * 255.0))
        return hexString
    }
    
    func getPixelColorAtPoint(point:CGPoint)->UIColor
    {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.translateBy(x: -point.x, y: -point.y)
        view.layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        pixel.deallocate(capacity: 4)
        return color
    }
    
    func pixel(in image1: UIImage, in image2: UIImage)
    {
        let width1 = Int(image1.size.width)
        _ = Int(image1.size.height)
        for x in 0 ..< Int(image1.size.width)
        {
            for y in 0 ..< Int(image1.size.height)
            {
                let cfData1:CFData = (image1.cgImage?.dataProvider?.data)!
                let cfData2:CFData = (image2.cgImage?.dataProvider?.data)!
                let pointer1 = CFDataGetBytePtr(cfData1)
                let pointer2 = CFDataGetBytePtr(cfData2)
                let bytesPerPixel = 4
                let offset = (x + y * width1) * bytesPerPixel
                let (r1,g1,b1,a1) = (pointer1![offset], pointer1![offset + 1], pointer1![offset + 2], pointer1![offset + 3])
                let (r2,g2,b2,a2) = (pointer2![offset], pointer2![offset + 1], pointer2![offset + 2], pointer2![offset + 3])
                print("Image1 = Red:\(r1), Green:\(g1), Blue:\(b1), Alpha:\(a1)")
                print("Image2 = Red:\(r2), Green:\(g2), Blue:\(b2), Alpha:\(a2)")
            }
        }
    }
}

extension UIColor
{
    func getColorDifference(fromColor: UIColor) -> Int
    {
        // get the current color's red, green, blue and alpha values
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // get the fromColor's red, green, blue and alpha values
        var fromRed:CGFloat = 0
        var fromGreen:CGFloat = 0
        var fromBlue:CGFloat = 0
        var fromAlpha:CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        let redValue = (max(red, fromRed) - min(red, fromRed)) * 255
        let greenValue = (max(green, fromGreen) - min(green, fromGreen)) * 255
        let blueValue = (max(blue, fromBlue) - min(blue, fromBlue)) * 255
        
        return Int(redValue + greenValue + blueValue)
    }
    
    func rgb() -> String?
    {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = "R: \(iRed) G: \(iGreen) B: \(iBlue) A: \(iAlpha)"
            //(iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        }
        else
        {
            // Could not extract RGBA components:
            return nil
        }
    }
}
