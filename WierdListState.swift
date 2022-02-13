import SwiftUI
import Combine

fileprivate class ResourceInteractor {
    private let passThroughStatePublisher = PassthroughSubject<ListState, Never>()
    
    public var publisher: AnyPublisher<ListState, Never> {
        self.passThroughStatePublisher.eraseToAnyPublisher()
    }
    
    public init() {}
    
    public func save(state: ListState) {
        self.passThroughStatePublisher.send(state)
    }
}

fileprivate struct IdentifiableInt: Identifiable {
    public let id: Int
}

fileprivate struct ListState {
    
    public init(listElementCount: Int) {
        self.ints = (0..<listElementCount).map { IdentifiableInt(id: $0) }
    }
    
    public var ints: [IdentifiableInt]
    
    public var listElementCount: Int {
        self.ints.count
    }
}

fileprivate class ListResourceManager: ObservableObject {
    private var interactor: ResourceInteractor
    private var timer: AnyCancellable? = nil
    private var stateSubscription: AnyCancellable? = nil
    
    @Published public var state: ListState
    
    public init(interactor: ResourceInteractor) {
        self.interactor = interactor
        self.state = ListState(listElementCount: 5)
        
        self.stateSubscription = interactor.publisher.sink { [weak self] newState in
            guard let self = self else { return }
            self.state = newState
        }
        
        self.timer = Timer.publish(every: 5.0, on: .main, in: .default).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            let newCount = (self.state.listElementCount > 0) ? (self.state.listElementCount - 1) : 0
            let newState = ListState(listElementCount: newCount)
            self.interactor.save(state: newState)
        }
    }
    
    deinit {
        self.timer?.cancel()
        self.stateSubscription?.cancel()
    }
}

fileprivate struct ResourceView: View {
    @ObservedObject private var resourceManager: ListResourceManager
    
    public init(resourceManager: ListResourceManager) {
        self.resourceManager = resourceManager
    }
    
    public var body: some View {
        List(self.resourceManager.state.ints) { identifiableInt in
            NavigationLink("link: \(identifiableInt.id)", destination: {
                Text("destination: \(identifiableInt.id)")
                        .padding()
            })
        }
    }
}

public struct WierdListState: View {
    @StateObject private var resourceManager = ListResourceManager(interactor: ResourceInteractor())
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ResourceView(resourceManager: self.resourceManager)
        }
    }
}
