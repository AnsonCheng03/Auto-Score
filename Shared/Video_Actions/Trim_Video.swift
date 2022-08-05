//
//  Trim_Video.swift
//  Auto Score
//
//  Created by Anson Cheng on 27/3/2022.
//

import SwiftUI
import AVKit

func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
    let asset = AVURLAsset(url: url)

    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

    let cmTime = CMTime(seconds: time, preferredTimescale: 60)
    let thumbnailImageRef: CGImage
    do {
        thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
    } catch let error {
        print("Error: \(error)")
        return UIImage()
    }
    return UIImage(cgImage: thumbnailImageRef)
}

struct Trim_Video: View {
    
    @Binding var ImportURL: URL
    @Binding var VideoCaptureTime:Int
    @Binding var UpperFrame:Int
    @Binding var LowerFrame:Int
    @Binding var DynWidth:Bool
    @Binding var SeqScan:Bool
    
    var body: some View {
        Text("開始裁剪")
        
        ZStack{
            
            ZStack{
                Color.black
                Image(uiImage: (imageFromVideo(url: ImportURL, at: TimeInterval(VideoCaptureTime)))!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            VStack {
                Color.gray.opacity(5).frame(height: CGFloat(UpperFrame)/100*400)
                Spacer()
            }
            
            VStack {
                Spacer()
                Color.gray.opacity(20).frame(height: CGFloat(LowerFrame)/100*400)
            }
            
        }.frame(height: 400)
        
        Stepper(value: $VideoCaptureTime, in: 1...Int(AVURLAsset(url: ImportURL).duration.seconds), step: Int(AVURLAsset(url: ImportURL).duration.seconds)/15 < 1 ? 1 : Int(AVURLAsset(url: ImportURL).duration.seconds)/15) {
            Text("定格秒數: \(VideoCaptureTime)/\(Int(AVURLAsset(url: ImportURL).duration.seconds))")
        }
        VStack{
            Stepper(value: $UpperFrame, in: 0...100, step: 1) {
                Text("上方遮罩  \(UpperFrame)%")
            }
            Stepper(value: $LowerFrame, in: 0...100, step: 1) {
                Text("下方遮罩 \(LowerFrame)%")
            }
        }
    }
}


struct Trim_Video_Previews: PreviewProvider {
    
    @State static var VideoURL:URL = URL(string: "https://images.all-free-download.com/footage_preview/mp4/ducks_2_6891413.mp4")!
    @State static var VideoCaptureTime : Int = 1
    @State static var PictureFrame = [10,40]
    @State static var Settings = [true,false] //DynWidth, SeqScan
    
    static var previews: some View {
        Trim_Video(ImportURL: $VideoURL, VideoCaptureTime: $VideoCaptureTime, UpperFrame: $PictureFrame[0], LowerFrame: $PictureFrame[1], DynWidth: $Settings[0], SeqScan: $Settings[1])
    }
}

