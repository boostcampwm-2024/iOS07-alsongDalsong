import SwiftUI

struct ASCacheKitDemoView: View {
    @StateObject private var viewModel = ASCacheKitDemoViewModel()
    @StateObject private var toastVM = ToastViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Spacer()
                    if let imageData = viewModel.imageData,
                       let uiImage = UIImage(data: imageData)
                    {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                    Spacer()
                }
                .overlay(alignment: .bottom) {
                    if toastVM.isPresented {
                        ToastView(vm: toastVM)
                    }
                }

                Divider()
                VStack {
                    Text("이미지 가져오기")
                        .font(.headline)
                    HStack {
                        Button("메모리") {
                            viewModel.loadCacheData(at: .onlyMemory)
                            toastVM.present(message: "메모리 캐시 접근")
                        }

                        Button("디스크") {
                            viewModel.loadCacheData(at: .onlyDisk)
                            toastVM.present(message: "디스크 캐시 접근")
                        }

                        Button("모두(다운로드 포함)") {
                            viewModel.loadCacheData(at: .both)
                            toastVM.present(message: "모든 캐시 접근 및 다운로드")
                        }
                    }
                }
                Divider()
                Button("뷰에서 이미지 제거") {
                    viewModel.imageData = nil
                    toastVM.present(message: "이미지 제거")
                }
                Divider()
                VStack {
                    Text("캐시 삭제")
                        .font(.headline)
                    HStack {
                        Button("메모리") {
                            viewModel.clearCache(at: .onlyMemory)
                            toastVM.present(message: "메모리 캐시 삭제")
                        }

                        Button("디스크") {
                            viewModel.clearCache(at: .onlyDisk)
                            toastVM.present(message: "디스크 캐시 삭제")
                        }

                        Button("모두") {
                            viewModel.clearCache(at: .both)
                            toastVM.present(message: "모든 캐시 삭제")
                        }
                    }
                }
            }
            .buttonStyle(.bordered)
            .navigationTitle("ASCacheKit Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ASCacheKitDemoView()
}
