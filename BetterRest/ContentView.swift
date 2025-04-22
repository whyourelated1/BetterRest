//
//  ContentView.swift
//  BetterRest
//
//  Created by whyourelated on 20.04.2025.
//
import CoreML //для использования ии
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    static var defaultWakeTime: Date { //статик чтобы св-во принадлежало структуре а не ее копии
        var component=DateComponents()
        component.hour=7
        component.minute=0
        return Calendar.current.date(from: component) ?? .now
    }
    var bedTime: Date{
        calculateBedTime()
    }
    var body: some View {
        NavigationStack{
                Form{
                    HStack(spacing: 0) { //по левому краю
                        Text("When do u want to wake up")
                            .font(.headline)
                        Spacer()
                        DatePicker("Please enter the time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Daily amount of coffee")
                            .font(.headline)
                        Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20) //автоматом меняет форму слова cup
                    }
                    
                    .alert("\(alertTitle)", isPresented: $showingAlert){
                        Button("OK"){}
                    } message: {
                        Text("\(alertMessage)")
                    }
                    
                    Text("Your recommended bedtime is \(calculateBedTime(), format: .dateTime.hour().minute())")
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(.rect(cornerRadius: 10))
                        .font(.title)
                        .padding()
                        .multilineTextAlignment(.center) // Центрируем текст
            }
            
            .navigationTitle("BetterRest")
            .font(.headline)
            /*.toolbar {
                Button("Calculate", action: calculateBedtime)
            }*/
            
        }
        .ignoresSafeArea()
        
    }
        func calculateBedTime()->Date{
            do {
                let config = MLModelConfiguration() //объект конфигурации, который может настроить модель
                let model = try SleepCalculator(configuration: config) //загрузка самой модели. try, потому что может завершиться ошибкой
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                let hour = (components.hour ?? 0) * 60 * 60
                let minute = (components.minute ?? 0) * 60
                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                return wakeUp - prediction.actualSleep
            } catch {
                showingAlert = true
                alertTitle = "Error"
                alertMessage = "Sorry, there was a problem calculating your bedtime."
                return .now
            }
        }
    }




#Preview {
    ContentView()
}
