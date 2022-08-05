//
//  ProcessVideo.swift
//  Auto Score
//
//  Created by Anson Cheng on 28/3/2022.
//

import SwiftUI
import AVKit

func cropToBounds(image: UIImage, topheight: Double, bottomheight: Double) -> UIImage {

    let cgimage = image.cgImage!
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    let contextSize: CGSize = contextImage.size

    let rect: CGRect = CGRect(x: 0.0, y: topheight/100.0*contextSize.height, width: CGFloat(contextSize.width), height: CGFloat((1 - topheight/100.0 - bottomheight/100.0)*contextSize.height))

    return UIImage(cgImage: cgimage.cropping(to: rect)! as CGImage, scale: image.scale, orientation: image.imageOrientation)
    
}

func findColors(_ image: UIImage) -> [UIColor] {
    let pixelsWide = Int(image.size.width)
    let pixelsHigh = Int(image.size.height)

    guard let pixelData = image.cgImage?.dataProvider?.data else { return [] }
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

    var imageColors: [UIColor] = []
    for x in 0..<pixelsWide {
        for y in 0..<pixelsHigh {
            let point = CGPoint(x: x, y: y)
            let pixelInfo: Int = ((pixelsWide * Int(point.y)) + Int(point.x)) * 4
            let color = UIColor(red: CGFloat(data[pixelInfo]) / 255.0,
                                green: CGFloat(data[pixelInfo + 1]) / 255.0,
                                blue: CGFloat(data[pixelInfo + 2]) / 255.0,
                                alpha: CGFloat(data[pixelInfo + 3]) / 255.0)
            imageColors.append(color)
        }
    }
    return imageColors
}

func compareImages(image1: UIImage, image2: UIImage) -> Double? {
    let data1 = findColors(image1)
    let data2 = findColors(image2)
    guard data1.count == data2.count else { return nil }
    var similarr = [Bool]()
    for i in data1.indices {
        similarr.append(isRGBSimilar(data1[i], data2[i], 0.1)) // <-- set epsilon
    }
    let simi = similarr.filter{$0}
    let result = (Double(simi.count * 100) / (Double(image1.size.width) * Double(image1.size.height)))
    return result
}

// compare 2 colors to be within d of each other
func isRGBSimilar(_ f: UIColor, _ t: UIColor, _ d: CGFloat) -> Bool {
    var r1: CGFloat = 0; var g1: CGFloat = 0; var b1: CGFloat = 0; var a1: CGFloat = 0
    f.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    
    var r2: CGFloat = 0; var g2: CGFloat = 0; var b2: CGFloat = 0; var a2: CGFloat = 0
    t.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    
    return abs(r1 - r2) <= d && abs(g1 - g2) <= d && abs(b1 - b2) <= d &&  abs(a1 - a2) <= d
}


struct ProcessVideo: View {
    
    @Binding var ImportURL: URL
    @Binding var VideoCaptureTime:Int
    @Binding var Frame: Array<Int>
    @Binding var DynWidth:Bool
    @Binding var SeqScan:Bool
    @State var PreviousImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    @State var NextImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    @State var AllImages : Array<UIImage> = []
    @State var Similarity : Array<Double> = [0]
    @State var SplitTime : Array<Double> = [0]
    
    var body: some View {
        ScrollView {
            VStack{
                ForEach(0..<Int(AllImages.count), id: \.self) { imageIdx in
                    Image(uiImage: AllImages[imageIdx]).resizable().aspectRatio(contentMode: .fit)
                }
            }
        }.onAppear {
            if(SeqScan == true) {
                NextImage = cropToBounds(image: imageFromVideo(url: ImportURL, at: TimeInterval(0))!, topheight: Double(Frame[0]), bottomheight: Double(Frame[1]))
                (1...Int(AVURLAsset(url: ImportURL).duration.seconds)).forEach{Capture in
                    PreviousImage = NextImage
                    NextImage = cropToBounds(image: imageFromVideo(url: ImportURL, at: TimeInterval(Capture))!, topheight: Double(Frame[0]), bottomheight: Double(Frame[1]))
                    let Similar = compareImages(image1: PreviousImage!,image2: NextImage!)!
                    if(Similar <= 80) {
                        AllImages.append(PreviousImage!)
                        Similarity.append(Similar)
                    }
                }
            } else {
                var Intervals = [[0.0,AVURLAsset(url: ImportURL).duration.seconds/2],[AVURLAsset(url: ImportURL).duration.seconds/2,AVURLAsset(url: ImportURL).duration.seconds]];
                var halftime:Double;
                
                while (Intervals.count > 0) {
                    halftime = Intervals[0][0] + Double(Intervals[0][1] - Intervals[0][0])/2

                    if(halftime - Intervals[0][0] >= 1) {
                        PreviousImage = cropToBounds(image: imageFromVideo(url: ImportURL, at: TimeInterval(Intervals[0][0]))!, topheight: Double(Frame[0]), bottomheight: Double(Frame[1]))
                        NextImage = cropToBounds(image: imageFromVideo(url: ImportURL, at: TimeInterval(Intervals[0][1]))!, topheight: Double(Frame[0]), bottomheight: Double(Frame[1]))
                        
                        if(compareImages(image1: PreviousImage!,image2: NextImage!)! >= 80) {
                            SplitTime.append(Intervals[0][0])
                            Intervals.append([Intervals[0][0],halftime])
                            Intervals.append([halftime,Intervals[0][1]])
                        }
                        Intervals.remove(at: 0)
                        Intervals = Intervals.sorted(by: {$0[0] < $1[0] })
                    }
                }
                
                SplitTime = Array(Set(SplitTime))
            
                NextImage = cropToBounds(image: imageFromVideo(url: ImportURL, at: TimeInterval(SplitTime[0]))!, topheight: Double(Frame[0]), bottomheight: Double(Frame[1]))
                                             
                SplitTime.forEach{time in
                    PreviousImage = NextImage
                    NextImage = cropToBounds(image: imageFromVideo(url: ImportURL, at: TimeInterval(time))!, topheight: Double(Frame[0]), bottomheight: Double(Frame[1]))
                    
                    if(compareImages(image1: PreviousImage!,image2: NextImage!)! >= 80) {
                       AllImages.append(cropToBounds(image: imageFromVideo(url: ImportURL, at: TimeInterval(time))!, topheight: Double(Frame[0]), bottomheight: Double(Frame[1])))
                       }
                }
            }
        }
    }
}


struct ProcessVideo_Previews: PreviewProvider {
    @State static var VideoURL:URL = URL(string: "https://images.all-free-download.com/footage_preview/mp4/ducks_2_6891413.mp4")!
    @State static var VideoCaptureTime : Int = 1
    @State static var PictureFrame = [10,40]
    @State static var Settings = [true,false] //DynWidth, SeqScan
    
    static var previews: some View {
        ProcessVideo(ImportURL: $VideoURL, VideoCaptureTime: $VideoCaptureTime, Frame: $PictureFrame, DynWidth: $Settings[0], SeqScan: $Settings[1])
    }
}

