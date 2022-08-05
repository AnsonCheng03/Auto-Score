//
//  ContentView.swift
//  Shared
//
//  Created by Anson Cheng on 27/3/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var VideoURL:URL = URL(string: "file:///")!
    @State var Nav_State : Int = 0
    @State var VideoCaptureTime : Int = 1
    @State var PictureFrame = [10,40]
    @State var Settings = [true,false] //DynWidth, SeqScan
    
    var body: some View {
        VStack {
            switch(Nav_State) {
                case 0:
                    Import_Video(ImportURL: $VideoURL)
                case 1:
                Trim_Video(ImportURL: $VideoURL, VideoCaptureTime: $VideoCaptureTime, UpperFrame: $PictureFrame[0], LowerFrame: $PictureFrame[1], DynWidth: $Settings[0], SeqScan: $Settings[1])
                case 2:
                ProcessVideo(ImportURL: $VideoURL, VideoCaptureTime: $VideoCaptureTime, Frame: $PictureFrame, DynWidth: $Settings[0], SeqScan: $Settings[1])
                default:
                    EmptyView()
            }
            
            HStack{
                if(Nav_State != 0) {
                    Button("上一頁"){
                        Nav_State -= 1
                    }
                }
                
                if(VideoURL != URL(string: "file:///")){
                    Button("下一頁"){
                        Nav_State += 1
                    }
                }
            }.frame(height: 20)
        }.frame(alignment: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
