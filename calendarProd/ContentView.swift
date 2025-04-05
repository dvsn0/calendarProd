import SwiftUI

struct ContentView: View {
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Sign In with Google") {
                    calendarManager.signIn()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                List(calendarManager.events, id: \.identifier) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.summary ?? "No Title")
                            .font(.headline)
                        
                        // Use event.start?.dateTime if available
                        if let dateTime = event.start?.dateTime?.date {
                            Text("Starts: \(dateTime, formatter: dateFormatter)")
                        }
                        // Otherwise, if it's an all-day event (date string)
                        else if let dateString = event.start?.date,
                                let date = isoDateFormatter.date(from: dateString) {
                            Text("Starts: \(date, formatter: dateFormatter)")
                        } else {
                            Text("Start time not available")
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Today's Events")
            }
        }
    }
    
    // Formatter for event times.
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    // ISO8601 formatter for all‑day events.
    var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
