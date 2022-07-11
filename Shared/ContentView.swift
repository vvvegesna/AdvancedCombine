//
//  ContentView.swift
//  Shared
//
//  Created by Vegesna, Vijay Varma on 7/9/22.
//

import SwiftUI
import Combine

class CombineDataService {
    //@Published var asynchData: String = ""
    //let currentValuePublisher = CurrentValueSubject<String, Error>("first publisher")
    let passThroughValuePublisher = PassthroughSubject<Int, Error>()
    init() {
        getFromSharedManager()
    }
    
    func getFromSharedManager()  {
        let items = Array(1...10)
        for x in items.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(x)) {
                self.passThroughValuePublisher.send(items[x])
                //self.asynchData = items[x]
                if x == items.indices.last {
                    self.passThroughValuePublisher.send(completion: .finished)
                }
            }
        }
    }
}

class AdvancedCombineViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    @Published var error: String = ""
    
    let dataService = CombineDataService()
    var cancellables = Set<AnyCancellable>()
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        dataService.passThroughValuePublisher
            //.first()
//            .tryFirst(where: { int in
//                if int == 3 {
//                    throw URLError(.badServerResponse)
//                }
//                return int > 4
//            })
            .last()
            .map({ String($0) })
            .sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self.error = "ERROR: \(error)"
            }
        } receiveValue: { [weak self] receivedValue in
            self?.dataArray.append(receivedValue)
        }
        .store(in: &cancellables)
    }
}

struct ContentView: View {
    @StateObject var viewModel = AdvancedCombineViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.title)
                        .fontWeight(.black)
                }
                if (!viewModel.error.isEmpty) {
                    Text(viewModel.error)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
    }
}
