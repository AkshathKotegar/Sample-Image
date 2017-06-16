//
//  PdftextViewController.swift
//  SampleImage
//
//  Created by apple on 13/04/17.
//  Copyright © 2017 Improstech. All rights reserved.
//

import UIKit
import TesseractOCR

class PdftextViewController: UIViewController, G8TesseractDelegate
{
    @IBOutlet weak var pdfImage: UIImageView!
    @IBOutlet weak var textExtract: UITextView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        convertPDFPageToImage(page: 2)
        if let tesseract = G8Tesseract(language: "eng")
        {
            tesseract.delegate = self
            tesseract.pageSegmentationMode = .auto
            tesseract.image = #imageLiteral(resourceName: "Cabeza.jpg").g8_blackAndWhite()
            tesseract.recognize()
            textExtract.text = tesseract.recognizedText
        }
    }
    
    func convertPDFPageToImage(page:Int)
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("swift.pdf").path
        
        do
        {
            let pdfdata = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.init(rawValue: 0))
            let pdfData = pdfdata as CFData
            let provider:CGDataProvider = CGDataProvider(data: pdfData)!
            let pdfDoc:CGPDFDocument = CGPDFDocument(provider)!
            _ = pdfDoc.numberOfPages;
            let pdfPage:CGPDFPage = pdfDoc.page(at: page)!
            var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
            pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
            print("\(pageRect.width) by \(pageRect.height)")
            
            UIGraphicsBeginImageContext(pageRect.size)
            let context:CGContext = UIGraphicsGetCurrentContext()!
            context.saveGState()
            context.translateBy(x: 0.0, y: pageRect.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.interpolationQuality = .high
            context.setRenderingIntent(.defaultIntent)
            context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
            context.drawPDFPage(pdfPage)
            context.restoreGState()
            let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            self.pdfImage.image = pdfImage
        }
        catch
        {

        }
    }
}
