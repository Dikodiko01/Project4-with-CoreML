//
//  ContentView.swift
//  project4
//
//  Created by Diar Orynbek on 27.11.2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var compomemts = DateComponents()
        compomemts.hour = 7
        compomemts.minute = 0
        
        return Calendar.current.date(from: compomemts) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time: ", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                Text("Dialy coffee intake")
                    .font(.headline)
                
                
                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            
        }
    }
    // так я хочу изменить структуру 
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculater(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minut = (components.minute ?? 0) * 60
            
            let predection = try model.prediction(wake: Double(hour + minut), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleptime = wakeUp - predection.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleptime.formatted(date: .omitted, time:  .shortened )
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bed time."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
