//
//  PdftoImgViewController.swift
//  SampleImage
//
//  Created by apple on 13/04/17.
//  Copyright © 2017 Improstech. All rights reserved.
//

import UIKit

class PdftoImgViewController: UIViewController
{
    @IBOutlet weak var PDFtoIMG: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        convertPDFPageToImage(page: 1)
        //PDFtoIMG.image = drawPDFfromURL(url: URL(string: "http://www.tutorialspoint.com/swift/swift_tutorial.pdf")!)
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
            context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
            context.drawPDFPage(pdfPage)
            context.restoreGState()
            let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            self.PDFtoIMG.image = pdfImage
        }
        catch
        {
            
        }
    }
}
    
    /*func drawPDFfromURL(url: URL) -> UIImage?
    {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
            
            ctx.cgContext.drawPDFPage(page);
        }
        
        return img
    }*/
