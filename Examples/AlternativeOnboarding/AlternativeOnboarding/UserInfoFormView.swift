import SwiftUI
import WhitelabelPaySDK

struct UserInfo {
	let firstName: String
	let lastName: String
	let email: String
	let dateOfBirth: Date
	let street: String
	let zip: String
	let city: String
	let phone: String
}

struct UserInfoFormView: View {

	typealias OnDidClose = (UserInfo) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = UserDefaults.standard.string(forKey: "pt.user.firstName") ?? "Test"
    @State private var lastName: String  = UserDefaults.standard.string(forKey: "pt.user.lastName")  ?? "Test"
    @State private var email: String     = UserDefaults.standard.string(forKey: "pt.user.email")     ?? "test@paymenttools.com"
    @State private var dateOfBirth: Date = UserDefaults.standard.object(forKey: "pt.user.dob") as? Date ?? Calendar.current.date(byAdding: .year, value: -20, to: .now)!
    @State private var street: String    = UserDefaults.standard.string(forKey: "pt.user.street") ?? "Friedrichstrasse"
    @State private var zip: String       = UserDefaults.standard.string(forKey: "pt.user.zip") ?? "10117"
    @State private var city: String      = UserDefaults.standard.string(forKey: "pt.user.city") ?? "Berlin"
    @State private var phone: String      = UserDefaults.standard.string(forKey: "pt.user.phone") ?? "+491511234567"

    @State private var isSaving = false
    @State private var showValidation = false
    @FocusState private var focused: Field?

	var onClose: OnDidClose

    enum Field { case first, last, email, street, zip, city, phone }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        PTField(title: "First name", text: $firstName)
                            .focused($focused, equals: .first)
                            .submitLabel(.next)
                            .onSubmit { focused = .last }

                        PTField(title: "Last name", text: $lastName)
                            .focused($focused, equals: .last)
                            .submitLabel(.next)
                            .onSubmit { focused = .email }

                        PTField(title: "Email", text: $email, keyboard: .emailAddress, autocapitalization: .never)
                            .focused($focused, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focused = .street }

						PTField(title: "Phone", text: $phone)
							.focused($focused, equals: .last)
							.submitLabel(.next)
							.onSubmit { focused = .phone }

                        PTDateField(title: "Date of birth", date: $dateOfBirth)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        PTField(title: "Street and no.", text: $street)
                            .focused($focused, equals: .street)
                            .submitLabel(.next)
                            .onSubmit { focused = .zip }

                        PTField(title: "ZIP code", text: $zip, keyboard: .numbersAndPunctuation)
                            .focused($focused, equals: .zip)
                            .submitLabel(.next)
                            .onSubmit { focused = .city }

                        PTField(title: "City", text: $city)
                            .focused($focused, equals: .city)
                            .submitLabel(.done)
                    }
                    .padding(.horizontal, 20)

                    if showValidation && !isFormValid {
                        Text(validationMessage)
                            .font(.system(size: 13))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }

                    Spacer(minLength: 80)
                }
            }
            .background(Color(.white))
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: saveAndContinue) {
                Text(isSaving ? "Saving…" : "Save & Import Bank Account")
                    .font(.system(size: 17))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(PTPrimaryButtonStyle())
            .disabled(isSaving)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .background(Color(.systemGroupedBackground))
        }
    }
	
	// MARK: -

	init(_ onClose: @escaping OnDidClose) {
		self.onClose = onClose
	}

    // MARK: - Actions

    private func saveAndContinue() {
		let info = UserInfo(firstName: firstName,
				 lastName: lastName,
				 email: email,
				 dateOfBirth: dateOfBirth,
				 street: street,
				 zip: zip,
				 city: city,
				 phone: phone)
		onClose(info)

    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(email)
    }

    private var validationMessage: String {
        if firstName.isEmpty || lastName.isEmpty { return "First and last name are required." }
        if !isValidEmail(email) { return "Please enter a valid email address." }
        return "Please complete the required fields."
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value)
    }
}

struct PTField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
            TextField("", text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .padding(14)
                .background(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct PTDateField: View {
    let title: String
    @Binding var date: Date
    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))

            Button {
                isPresented = true
            } label: {
                HStack {
                    Text(dateFormatted(date))
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "calendar")
                        .imageScale(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isPresented) {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isPresented = false
                        }
                        .padding()
                    }

                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .presentationDetents([.height(300), .medium])
            }
        }
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct PTPrimaryButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: SwiftUI.ButtonStyle.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(configuration.isPressed
                          ? Color.purple.opacity(0.85)
                          : Color.purple
                    )
            )
            .foregroundColor(.white)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
		UserInfoFormView { _ in
		}
    }
}
