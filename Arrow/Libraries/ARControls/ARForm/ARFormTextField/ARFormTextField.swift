//
//  ARFormTextField.swift
//  Arrow
//
//  Created by Kiarash on 12/2/16.
//  Copyright © 2016 Arrow Application, LLC. All rights reserved.
//

import UIKit

@IBDesignable
public class ARFormTextField: ARControl {
    
    override var kNib: UINib? { return R.nib.aRFormTextField() }
    
    fileprivate let kValidationHeightDiff: CGFloat = 15.0
    
    @IBOutlet public private(set) weak var textField: UITextField!
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    
    fileprivate var defaultSeparatorLineHeightConst: CGFloat = 1.0
    
    // MARK: - IBInspectable Variables
    
    @IBInspectable public var errorMessageTextColor: UIColor = Appearance.errorMessageTextColor
    
    @IBInspectable public var messageFont: UIFont = Appearance.messageFont {
        didSet {
            messageLabel.font = messageFont
        }
    }
    
    @IBInspectable public var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    @IBInspectable public var placeholderTextColor: UIColor = Appearance.placeholderTextColor {
        didSet {
            textField.setPlaceholder(color: placeholderTextColor)
        }
    }
    
    @IBInspectable public var separatorLineFocusedColor: UIColor = Appearance.separatorLineFocusedColor
    
    @IBInspectable public var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
            format(textField: textField)
        }
    }
    
    @IBInspectable public var textColor: UIColor = Appearance.textColor {
        didSet {
            textField.textColor = textColor
        }
    }
    
    @IBInspectable public var textFont: UIFont = Appearance.textFont {
        didSet {
            textField.font = textFont
            // Separator line's thickness varies based on font weight.
            updateSeparatorLine()
        }
    }
    
    public var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }
    
    // MARK: - Validation Related Members
    
    @IBInspectable public var validationErrorMessage: String?
    
    public var invalid: Bool {
        let isValid = validationTester?(self.text) ?? true
        return isValid == false
    }
    
    public var validationTester: ((String?) -> Bool)?
    public var textFormatter: ((NSAttributedString) -> NSAttributedString)?
    
    fileprivate var isShowingErrorMessage: Bool = false {
        didSet {
            updateSeparatorLine()
            messageLabel.textColor = isShowingErrorMessage ? errorMessageTextColor : placeholderTextColor
            messageLabel.isHidden = !isShowingErrorMessage
        }
    }
    
    fileprivate var separatorLineColor: UIColor {
        if isShowingErrorMessage == true {
            return errorMessageTextColor
        }
        return isFirstResponder ? separatorLineFocusedColor : placeholderTextColor
    }
    
    // MARK: - Initializers
    
    deinit {
        textField.removeTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        textField.removeTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        textField.removeTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
    }
    
    override func viewDidLoad() {
        textField.text = text
        textField.delegate = textFieldDelegate
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        textField.placeholder = placeholder
        messageLabel.isHidden = true
        
        // Customize appearance.
        textField.font = textFont
        messageLabel.font = messageFont
        
        textField.textColor = textColor
        textField.setPlaceholder(color: placeholderTextColor)
        messageLabel.textColor = textColor
        separatorLine.backgroundColor = placeholderTextColor
        separatorLine.clipsToBounds = true
        
        // Add tap gesture recognizer.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(formTextFieldTapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setErrorMessage(_ message: String?, show: Bool) {
        isShowingErrorMessage = show
        let visibleMessage = message ?? (validationErrorMessage ?? " ")
        messageLabel.text = show ? visibleMessage : " "  // Hack to preserve messageLabel's height.
        layoutIfNeeded()
    }
    
    fileprivate func format(textField: UITextField) {
        guard let textFormatter = textFormatter, let attributedText = textField.attributedText else {
            return
        }
        textField.attributedText = textFormatter(attributedText)
    }
    
    /// Update separator line's thickness based on text field's state and font weight.
    fileprivate func updateSeparatorLine() {
        let isBold = textField.font?.fontDescriptor.symbolicTraits.contains(.traitBold) ?? false
        let lineThicknessMult: CGFloat = isFirstResponder ? (isBold ? 3.0 : 2.0) : (isBold ? 2.0 : 1.0)
        let separatorLineThickness = defaultSeparatorLineHeightConst * lineThicknessMult
        UIView.animate(withDuration: 0.1) {
            self.separatorLine.backgroundColor = self.separatorLineColor
            self.separatorLineHeight.constant = separatorLineThickness
            self.separatorLine.layer.cornerRadius = separatorLineThickness / 2.0
        }
    }
    
    // MARK: - Overloaded Members
    
    public override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
}

// MARK: - Event Handlers

extension ARFormTextField {
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        format(textField: textField)
    }
    
    @objc func textFieldEditingDidBegin(_ textField: UITextField) {
        updateSeparatorLine()
    }
    
    @objc func textFieldEditingDidEnd(_ textField: UITextField) {
        updateSeparatorLine()
    }
    
    @objc func formTextFieldTapped(_ tapRecognizer: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
}

// MARK: - Public Convenience Methods

extension ARFormTextField {
    
    public func setup(placeholder: String?, isSecureTextEntry: Bool = false, keyboardType: UIKeyboardType = .default, validationMessage: String? = nil, autoCapitalization: Bool = false) {
        self.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecureTextEntry
        textField.autocapitalizationType = (autoCapitalization ? .sentences : .none)
        validationErrorMessage = validationMessage
    }
    
    public func show(regularMessage message: String?) {
        setErrorMessage(message, show: true)
        messageLabel.textColor = textColor
        separatorLine.backgroundColor = separatorLineColor
    }
    
    public func show(errorMessage message: String?) {
        setErrorMessage(message, show: true)
    }
    
    public func hideErrorMessage() {
        setErrorMessage(nil, show: false)
    }
    
}
