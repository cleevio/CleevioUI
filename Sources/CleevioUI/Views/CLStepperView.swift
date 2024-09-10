//
//  StepperView.swift
//  Pods
//
//  Created by Diego on 25/01/22.
//

#if canImport(UIKit) && !os(watchOS)
import SwiftUI

// TODO: consider better support of custom set styles (and with that, remove isLoading entirely, isDisabled should be driven only through Environment(\.isEnabled)
@available(iOS 14.0, *)
public struct CLStepperView: View {
    public enum Style {
        case minimal
        case colorful

        var decreaseBackgroundColor: Color {
            switch self {
            case .minimal:
                return Color.white
            case .colorful:
                return Color(.systemBlue)
            }
        }
        
        var decreaseForegroundColor: Color {
            switch self {
            case .minimal:
                return Color(.label)
            case .colorful:
                return Color.white
            }
        }
        
        var increaseBackgroundColor: Color {
            switch self {
            case .minimal:
                return Color.white
            case .colorful:
                return Color(.systemBlue)
            }
        }
        
        var increaseForegroundColor: Color {
            switch self {
            case .minimal:
                return Color(.label)
            case .colorful:
                return Color.white
            }
        }
    }
    
    @Binding var quantity: Int
    @Binding var isLoading: Bool
    
    let increaseButtonDisabled: Bool
    let backgroundColor: Color
    let style: Style
    let loadingScale: CGFloat
    
    public init(
        increaseButtonDisabled: Bool,
        quantity: Binding<Int>,
        backgroundColor: Color,
        isLoading: Binding<Bool>,
        style: Style = .colorful,
        loadingScale: CGFloat = 1.0
    ) {
        self.increaseButtonDisabled = increaseButtonDisabled
        self.backgroundColor = backgroundColor
        self.style = style
        self.loadingScale = loadingScale
        self._quantity = quantity
        self._isLoading = isLoading
    }
    
    public var body: some View {
        HStack {
            Button(action: {
                if quantity > 0 {
                    quantity -= 1
                }
            }, label: {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .style(
                        withStroke: Color(.systemBlue),
                        lineWidth: style == .minimal ? 2 : 0,
                        fill: style.decreaseBackgroundColor
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "minus")
                            .foregroundColor(style.decreaseForegroundColor)
                    )
            })
            .disabled(isLoading)
            
            Spacer()
            if isLoading {
                ProgressView()
                    .progressViewStyle(DotsProgressViewStyle(scale: loadingScale))
                    .frame(width: 50, height: 10)
            } else {
                Text("\(quantity)")
                    .font(.body)
            }
            Spacer()
            
            Button(action: {
                quantity += 1
            }, label: {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .style(
                        withStroke: Color(.systemBlue),
                        lineWidth: style == .minimal ? 2 : 0,
                        fill: style.increaseBackgroundColor
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundColor(style.increaseForegroundColor.opacity(increaseButtonDisabled ? 0.4 : 1))
                    )
            })
            .disabled(increaseButtonDisabled || isLoading)
        }
        .background(backgroundColor)
    }
}

@available(iOS 14.0, *)
struct CLStepperViewPreview: PreviewProvider {
    static var previews: some View {
        CLStepperView(
            increaseButtonDisabled: false,
            quantity: .constant(2),
            backgroundColor: .gray.opacity(0.2),
            isLoading: .constant(false)
        )
        .frame(size: CGSize(width: 150, height: 50))
    }
}
#endif
