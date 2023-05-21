import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 320)
                    .padding()
                
                NavigationLink(destination: ChatView()) {
                    Text("Start Chat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 70)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarHidden(true)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
