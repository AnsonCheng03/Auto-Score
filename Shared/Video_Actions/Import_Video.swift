//
//  Add_Video.swift
//  Auto Score
//
//  Created by Anson Cheng on 27/3/2022.
//

import UIKit
import SwiftUI
import AVKit

struct Import_Video: View {

    @Binding var ImportURL: URL
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentActionScheet = false
    
    var body: some View {
        VStack {
            Button("選擇影片"){
                self.shouldPresentImagePicker = true
                //shouldPresentActionScheet = true
            }.actionSheet(isPresented: $shouldPresentActionScheet) { () -> ActionSheet in
                ActionSheet(title: Text("Choose mode"), message: Text("Please choose your preferred mode to set your profile video"), buttons: [
                        ActionSheet.Button.default(Text("Photo Library"), action: {
                            self.shouldPresentImagePicker = true
                        }),
                        ActionSheet.Button.cancel()
                    ])
            }
            
            VideoPlayer(player: AVPlayer(url: ImportURL))
                .frame(height: 400)
                .sheet(isPresented: $shouldPresentImagePicker) {
                    ImagePicker(sourceType: .photoLibrary) { video in
                        ImportURL = video;
                        print(video)

                    }
                }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode)
    private var presentationMode

    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (URL) -> Void

    final class Coordinator: NSObject,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {

        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (URL) -> Void

        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (URL) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            onImagePicked(uiImage)
            presentationMode.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.movie"]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

}


struct Import_Video_Previews: PreviewProvider {

    @State static var VideoURL:URL = URL(string: "https://images.all-free-download.com/footage_preview/mp4/ducks_2_6891413.mp4")!
    
    static var previews: some View {
        Import_Video(ImportURL: $VideoURL)
    }
    
}

