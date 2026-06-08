//
//  EditImageReducer.swift
//  TCA
//
//  Created by 정욱 on 5/16/26.
//

import ComposableArchitecture
import SwiftUI
import Photos
import SwiftData

@Reducer
struct EditImageReducer {
    
    @ObservableState
    struct State {
        var userImage: Image?
        var assets: [PHAsset] = []
        var selectedPhoto: (id: String, data: Data)?
        // nil이면 사라짐, nil 아니면 뜸 - 트리 기반
        @Presents var alert: AlertState<Action>?
    }
    
    enum Action {
        case onAppear(image: Data?)
        case setUserImageData(Data?)
        case setUserImage(Image)
        case authResult(Bool)
        case onSelectPhoto(id: String, data: Data)
        // alert에서 발생하는 액션을 Reducer가 받을 수 있게 하는 통로
        case onEditSuccess(Data)
        case onEditFail(String)
        case alert(PresentationAction<Action>)
    }
    
    var body: some Reducer<State, Action>  {
        Reduce { state, action in
            switch action  {
            case let .onAppear(imageData):
                // 비동기 함수 사용할때는 Effect.run 라는 Effect 사용을 해야함
                // Reducer는 항상 액션을 받으면 Effect를 리턴해야함
                return Effect.run { send in
                    let isAuth = await PhotoManager.requestAuthorization()
                    await send(.authResult(isAuth))
                    await send(.setUserImageData(imageData))
                }
                
            case let .authResult(isAuth):
                if isAuth { // 권한 허용이면 이미지 가져오기
                    let assets = PhotoManager.getAssets()
                    state.assets = assets
                } else {
                    state.alert = AlertState.createAlert(
                        type: .error(message: "권한이 없습니다")
                    )
                }
                
                // Data 타입을 받아서 Image 타입으로 변환하여 저장을 위한 액션으로 전달
            case let .setUserImageData(data):
                guard let data, let uiImage = UIImage(data: data) else {
                    return .none
                }
                
                return .send(.setUserImage(Image(uiImage: uiImage)))
                
            case let .setUserImage(image):
                state.userImage = image
                return .none
            case let .onSelectPhoto(id, data):
                state.selectedPhoto = (id: id, data: data)
            case let .onEditSuccess(data):
                return .send(.setUserImageData(data))
            case let .onEditFail(error):
                state.alert = AlertState.createAlert(type: .error(message: error))
            case .alert:
                return .none
            }
            return .none
        }
    }
}

struct EditImageView: View {
    
    @Bindable var store: StoreOf<EditImageReducer>
    
    let columns: [GridItem] = .init(
        repeating: .init(.flexible()),
        count: 3
    )
    
    @Query private var users: [User]
    @Environment(\.modelContext) var context
    
    private var user: User? {
        users.first
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("선택된 이미지")
                
                // 선택된 이미지
                // 묶어서 속성 적용을 위해 Group으로 감쌓아줌
                Group {
                    if let image = store.userImage {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                // PHAsset 안에 localIdentifier가 있어서 이걸 그대로 사용
                ForEach(store.assets, id: \.localIdentifier) { asset in
                    let isSelectedImage = store.selectedPhoto?.id == asset.localIdentifier
                    AssetImageView(asset: asset, isSelected: isSelectedImage) { data in
                        store.send(.onSelectPhoto(id: asset.localIdentifier, data: data))
                    }
                    .clipped()
                    .cornerRadius(8)
                }
            }
            .padding(8)
        }
        .toolbar(content: {
            ToolbarItem {
                Button(action: {
                    editImage(data: store.selectedPhoto?.data)
                }) {
                    Text("저장")
                }
            }
        })
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.onAppear(image: user?.imageData))
        }
    }
    
    func editImage(data: Data?) {
        guard let data else { return }
        user?.imageData = data
        do {
            try context.save()
            store.send(.onEditSuccess(data))
        } catch let error {
            store.send(.onEditFail(error.localizedDescription))
        }
        
    }
}

private struct AssetImageView: View {
    
    let asset: PHAsset
    let isSelected: Bool
    let onTap: (Data) -> Void // 선택값을 전달하기 위함
    
    let imageWidth = (UIScreen.main.bounds.width - 16 - 20) / 3
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .onTapGesture(perform: {
                        if let data = image.jpegData(compressionQuality: 1.0) {
                            onTap(data)
                        }
                    })
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(width: imageWidth, height: imageWidth)
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .frame(width: 20, height: 20)
            }
        }
        .onAppear {
            PhotoManager.fetchImage(asset: asset) { uiImage in
                image = uiImage
            }
        }
    }
}
