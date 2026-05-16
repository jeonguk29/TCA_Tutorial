import SwiftUI
import SwiftData

@main
struct AppStoreApp: App {
    var body: some Scene {
        WindowGroup {
            MyPageView()
        }
        .modelContainer(modelContainer)
    }
}

private var modelContainer: ModelContainer = {
    let schema = Schema([User.self])
    
    let modelConfigutaion = ModelConfiguration(schema: schema)
    
    // 모델 컨테이너문 사용하기 위해서는 do-catch 필요
    do {
        let container = try ModelContainer(for: schema, configurations: modelConfigutaion)
        Task { @MainActor in // 왜 메인에거에서 처리를 한거지?
            setInitialData(context: container.mainContext) // 어웨잇이라 Task로 감쌓았다고함 자동 생략인가?
        }
        return container
    } catch {
        fatalError("ModelContainer 생성 실패")
    }
    
}()


// 초기 값 넣어주기 컨텍스트 접근해서 FetchDescriptor로 가져오는것 가져왔는데 비어있으면 넣어주는것임 값을
private func setInitialData(context: ModelContext) {
    let descriptor = FetchDescriptor<User>()  // 우리가 등록한 스키마 User에서 값을 가져오는 것임
    if let isEmpty = try? context.fetch(descriptor).isEmpty, isEmpty {
        let user = User(name: "Chris", email: "chris.bumstead@gmail.com")
        context.insert(user)
        try? context.save()
    }
}
