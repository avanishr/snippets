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
