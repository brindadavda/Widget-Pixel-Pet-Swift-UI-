//
//  TamagochiWidgetLiveActivity.swift
//  TamagochiWidget
//
//  Created by Systems
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TamagochiWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var firstTamagochiImageData: Data
        var secondTamagochiImageData: Data?
    }

    // Fixed non-changing properties about your activity go here!
    var firstTamagochiName: String
    var secondTamagochiName: String?
}

struct TamagochiWidgetLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TamagochiWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            makeMinView(with: context)
                .activityBackgroundTint(Color(red: 0.62, green: 0.52, blue: 0.98))
                .activitySystemActionForegroundColor(Color.black)
                .font(
                    Font.custom("DM Sans", size: 20)
                        .weight(.medium)
                )
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    if let image = UIImage(data: context.state.firstTamagochiImageData) {
                        getDynamicIslandImage(with: image, and: CGSize(width: 40, height: 40))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let secondTamagochiImageData = context.state.secondTamagochiImageData, let secondImage = UIImage(data: secondTamagochiImageData) {
                        getDynamicIslandImage(with: secondImage, and: CGSize(width: 40, height: 40))
                            .scaleEffect(x: -1, y: 1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Group {
                            Link("Info", destination: URL(string: "tamagochiApp://open-info")!)
                                .foregroundColor(.gray)
                                .rectangleBackground(with: .gray, backgroundColor: .clear, cornerRadius: 44)
                            Link("Feed", destination: URL(string: "tamagochiApp://open-feed")!)
                                .foregroundColor(.yellow)
                                .rectangleBackground(with: .yellow, backgroundColor: .clear, cornerRadius: 44)
                            Link("Play", destination: URL(string: "tamagochiApp://open-play")!)
                                .foregroundColor(.red)
                                .rectangleBackground(with: .red, backgroundColor: .clear, cornerRadius: 44)
                        }
                        .font(
                            Font.custom("DM Sans", size: 20)
                                .weight(.medium)
                        )
                    }
                    .frame(height: 40)
                    .padding(.all)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(getMiddleText(from: context))
                        .foregroundColor(.white)
                        .font(
                            Font.custom("DM Sans", size: 20)
                                .weight(.medium)
                        )
                }
            } compactLeading: {
                if let image = UIImage(data: context.state.firstTamagochiImageData) {
                    getDynamicIslandImage(with: image, and: CGSize(width: 30, height: 30))
                }
            } compactTrailing: {
                if let secondTamagochiImageData = context.state.secondTamagochiImageData, let secondImage = UIImage(data: secondTamagochiImageData) {
                    getDynamicIslandImage(with: secondImage, and: CGSize(width: 30, height: 30))
                        .scaleEffect(x: -1, y: 1)
                }
            } minimal: {
                if let image = UIImage(data: context.state.firstTamagochiImageData) {
                    getDynamicIslandImage(with: image, and: CGSize(width: 30, height: 30))
                }
            }
        }
    }
    
    private func makeMinView(with context: ActivityViewContext<TamagochiWidgetAttributes>) -> some View {
        HStack {
            Spacer()
            if let image = UIImage(data: context.state.firstTamagochiImageData) {
                Image(uiImage: image)
                    .frame(width: 30, height: 30)
                    .padding(.all)
            }
            Spacer()
            Text(getMiddleText(from: context))
                .foregroundColor(.black)
            Spacer()
            if let secondTamagochiImageData = context.state.secondTamagochiImageData, let secondImage = UIImage(data: secondTamagochiImageData) {
                Image(uiImage: secondImage)
                    .frame(width: 30, height: 30)
                    .padding(.all)
                    .scaleEffect(x: -1, y: 1)
            }
            Spacer()
        }
    }
    
    private func getDynamicIslandImage(with uiImage: UIImage, and frame: CGSize) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(width: frame.width, height: frame.height)
            .contentTransition(.identity)
    }
    
    private func getMiddleText(from context: ActivityViewContext<TamagochiWidgetAttributes>) -> String {
        var result = context.attributes.firstTamagochiName.capitalizeFirstLetter()
        if let secondName = context.attributes.secondTamagochiName {
            result.append(" & \(secondName.capitalizeFirstLetter())")
        }
        return result
    }
    
}

struct TamagochiWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = TamagochiWidgetAttributes(firstTamagochiName: Cats.allCases.first!.rawValue, secondTamagochiName: Cats.allCases.last!.rawValue)
    static let contentState = TamagochiWidgetAttributes.ContentState(firstTamagochiImageData: Data())

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
