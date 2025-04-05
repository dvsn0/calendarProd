import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST

@MainActor
class CalendarManager: ObservableObject {
    @Published var events: [GTLRCalendar_Event] = []
    
    // Replace with your actual client ID.
    private let clientID = "removed"
    
    // Google Calendar service instance.
    private let service = GTLRCalendarService()
    
    /// Initiates Google Sign‑In using the new closure‑based API.
    func signIn() {
        // Retrieve the root view controller using connectedScenes.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("Unable to retrieve root view controller")
            return
        }
        
        // Create configuration with your client ID.
        let config = GIDConfiguration(clientID: clientID)
        
        // Sign in using the closure‑based API.
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootVC) { [weak self] user, error in
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                return
            }
            
            guard let self = self, let user = user else { return }
            
            // Set the service authorizer from the user's authentication.
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            
            // Fetch today's events.
            self.fetchTodayEvents()
        }
    }
    
    /// Fetches events from the primary calendar for the current day.
    func fetchTodayEvents() {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        var comps = DateComponents()
        comps.day = 1
        comps.second = -1
        
        guard let endOfDay = calendar.date(byAdding: comps, to: startOfDay) else {
            print("Error computing end of day")
            return
        }
        
        query.timeMin = GTLRDateTime(date: startOfDay)
        query.timeMax = GTLRDateTime(date: endOfDay)
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        
        service.executeQuery(query) { [weak self] (_, result, error) in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            guard let self = self,
                  let eventsResult = result as? GTLRCalendar_Events,
                  let items = eventsResult.items else {
                print("No events found or casting error.")
                return
            }
            
            DispatchQueue.main.async {
                self.events = items
            }
        }
    }
}
