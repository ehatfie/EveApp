import SwiftUI


struct IPDetailInputGroup1: Identifiable {
  var id: String { groupName }
  let groupName: String
  let content: [IPDetailInput]
}

struct ReactionFilterConfig {
    let title: String
    let content: [IdentifiedString]
}

struct ReactionFilterView: View {
    var items: ReactionFilterConfig
    
    @State var selectionSet: Set<Int64> = Set<Int64>()
    @Binding var expandedSet: Set<Int64> //= Set<Int64>()
    
    var body: some View {
        VStack {
            Text(items.title)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(items.content.indexed(), id: \.element) { index, element in
                        row1(for: element, expandable: true)
                        if index < items.content.count {
                            Divider()
                        }
                        if expandedSet.contains(element.id) {
                            
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(element.content!) { subItem in
                                    row1(for: subItem)
                                }
                            }.padding(.leading)
                        }
                    }
                }.padding(.horizontal)
            }

        }.padding()
    }
    
    @ViewBuilder
    func row(for item: IdentifiedString) -> some View {
        VStack {
            HStack {
                if selectionSet.contains(item.id) {
                    Image(systemName: "checkmark")
                } else {
                    Image(systemName: "square")
                }
                
                Text(item.value)
            }.onTapGesture {
                if !selectionSet.insert(item.id).inserted {
                    selectionSet.remove(item.id)
                }
            }
        }
    }
    @ViewBuilder
    func row1(
        for item: IdentifiedString,
        expandable: Bool = false
    ) -> some View {
        HStack {
            if !selectionSet.contains(item.id) {
                Image(systemName: "checkmark")
            } else {
                Image(systemName: "square")
            }
            
            Text(item.value)
            Text("count \(item.content?.count ?? -1)")
            Spacer()
            if expandable {
                if !expandedSet.contains(item.id) {
                    Image(systemName: "chevron.down")
                } else {
                    Image(systemName: "chevron.up")
                }
            }
            
        }.onTapGesture {
            if !selectionSet.insert(item.id).inserted {
                selectionSet.remove(item.id)
            }
            
            if !expandedSet.insert(item.id).inserted {
                expandedSet.remove(item.id)
            }
        }
    }
}


