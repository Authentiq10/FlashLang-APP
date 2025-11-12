//
//  Models.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import Foundation

enum LearningStatus: String, Codable, CaseIterable {
    case new = "new"
    case familiar = "familiar"
    case learned = "learned"
    
    var displayName: String {
        switch self {
        case .new: return "New"
        case .familiar: return "Familiar"
        case .learned: return "Learned"
        }
    }
    
    var color: String {
        switch self {
        case .new: return "red"
        case .familiar: return "orange"
        case .learned: return "green"
        }
    }
    
    var icon: String {
        switch self {
        case .new: return "questionmark.circle"
        case .familiar: return "eye.circle"
        case .learned: return "checkmark.circle.fill"
        }
    }
}

struct Category: Identifiable, Codable {
    var id = UUID()
    let name: String
    let icon: String
    let flashcards: [Flashcard]
}

struct Flashcard: Identifiable, Codable {
    var id = UUID()
    let english: String
    let german: String
    let exampleSentence: String
    var learningStatus: LearningStatus = .new
}

struct UserProgress: Codable {
    var cardStatuses: [UUID: LearningStatus] = [:]
    var showOnlyUnlearned: Bool = false
    var darkMode: Bool = false
}

// Sample vocabulary data
extension Category {
    static let sampleCategories: [Category] = [
        Category(name: "Food", icon: "fork.knife", flashcards: [
            Flashcard(english: "Apple", german: "Apfel", exampleSentence: "Ich esse einen roten Apfel."),
            Flashcard(english: "Bread", german: "Brot", exampleSentence: "Das Brot ist frisch gebacken."),
            Flashcard(english: "Cheese", german: "Käse", exampleSentence: "Ich mag Schweizer Käse sehr."),
            Flashcard(english: "Milk", german: "Milch", exampleSentence: "Die Milch ist kalt."),
            Flashcard(english: "Water", german: "Wasser", exampleSentence: "Kann ich ein Glas Wasser haben?"),
            Flashcard(english: "Coffee", german: "Kaffee", exampleSentence: "Ich trinke gerne Kaffee am Morgen."),
            Flashcard(english: "Beer", german: "Bier", exampleSentence: "Ein kaltes Bier, bitte!"),
            Flashcard(english: "Wine", german: "Wein", exampleSentence: "Der Wein schmeckt sehr gut."),
            Flashcard(english: "Chicken", german: "Huhn", exampleSentence: "Ich esse gerne gebratenes Huhn."),
            Flashcard(english: "Fish", german: "Fisch", exampleSentence: "Der Fisch ist sehr frisch."),
            Flashcard(english: "Rice", german: "Reis", exampleSentence: "Ich koche Reis zum Abendessen."),
            Flashcard(english: "Potato", german: "Kartoffel", exampleSentence: "Die Kartoffeln sind weich."),
            Flashcard(english: "Tomato", german: "Tomate", exampleSentence: "Die Tomate ist rot und reif."),
            Flashcard(english: "Carrot", german: "Karotte", exampleSentence: "Karotten sind gut für die Augen."),
            Flashcard(english: "Banana", german: "Banane", exampleSentence: "Ich esse eine gelbe Banane."),
            Flashcard(english: "Orange", german: "Orange", exampleSentence: "Die Orange ist süß und saftig."),
            Flashcard(english: "Egg", german: "Ei", exampleSentence: "Ich koche ein Ei zum Frühstück."),
            Flashcard(english: "Butter", german: "Butter", exampleSentence: "Die Butter ist weich."),
            Flashcard(english: "Sugar", german: "Zucker", exampleSentence: "Ich nehme Zucker in meinen Tee."),
            Flashcard(english: "Salt", german: "Salz", exampleSentence: "Das Essen braucht mehr Salz."),
            Flashcard(english: "Soup", german: "Suppe", exampleSentence: "Die Suppe ist heiß und lecker.")
        ]),
        Category(name: "Travel", icon: "airplane", flashcards: [
            Flashcard(english: "Airport", german: "Flughafen", exampleSentence: "Der Flughafen ist sehr groß."),
            Flashcard(english: "Hotel", german: "Hotel", exampleSentence: "Wir übernachten in einem Hotel."),
            Flashcard(english: "Train", german: "Zug", exampleSentence: "Der Zug kommt in 5 Minuten."),
            Flashcard(english: "Bus", german: "Bus", exampleSentence: "Ich fahre mit dem Bus zur Arbeit."),
            Flashcard(english: "Ticket", german: "Fahrkarte", exampleSentence: "Haben Sie eine Fahrkarte?"),
            Flashcard(english: "Passport", german: "Reisepass", exampleSentence: "Vergessen Sie nicht Ihren Reisepass!"),
            Flashcard(english: "Map", german: "Karte", exampleSentence: "Können Sie mir die Karte zeigen?"),
            Flashcard(english: "Suitcase", german: "Koffer", exampleSentence: "Mein Koffer ist sehr schwer."),
            Flashcard(english: "Plane", german: "Flugzeug", exampleSentence: "Das Flugzeug startet in 10 Minuten."),
            Flashcard(english: "Car", german: "Auto", exampleSentence: "Wir fahren mit dem Auto in Urlaub."),
            Flashcard(english: "Bicycle", german: "Fahrrad", exampleSentence: "Ich fahre mit dem Fahrrad zur Arbeit."),
            Flashcard(english: "Boat", german: "Boot", exampleSentence: "Das Boot fährt über den See."),
            Flashcard(english: "Taxi", german: "Taxi", exampleSentence: "Ich nehme ein Taxi zum Flughafen."),
            Flashcard(english: "Street", german: "Straße", exampleSentence: "Die Straße ist sehr breit."),
            Flashcard(english: "Bridge", german: "Brücke", exampleSentence: "Die Brücke ist sehr alt."),
            Flashcard(english: "Mountain", german: "Berg", exampleSentence: "Der Berg ist sehr hoch."),
            Flashcard(english: "Beach", german: "Strand", exampleSentence: "Wir gehen zum Strand."),
            Flashcard(english: "City", german: "Stadt", exampleSentence: "Die Stadt ist sehr groß."),
            Flashcard(english: "Country", german: "Land", exampleSentence: "Deutschland ist ein schönes Land."),
            Flashcard(english: "Tourist", german: "Tourist", exampleSentence: "Ich bin ein Tourist in Berlin."),
            Flashcard(english: "Guide", german: "Führer", exampleSentence: "Der Führer zeigt uns die Sehenswürdigkeiten.")
        ]),
        Category(name: "Colors", icon: "paintpalette", flashcards: [
            Flashcard(english: "Red", german: "Rot", exampleSentence: "Das Auto ist rot."),
            Flashcard(english: "Blue", german: "Blau", exampleSentence: "Der Himmel ist blau."),
            Flashcard(english: "Green", german: "Grün", exampleSentence: "Das Gras ist grün."),
            Flashcard(english: "Yellow", german: "Gelb", exampleSentence: "Die Sonne ist gelb."),
            Flashcard(english: "Black", german: "Schwarz", exampleSentence: "Die Nacht ist schwarz."),
            Flashcard(english: "White", german: "Weiß", exampleSentence: "Der Schnee ist weiß."),
            Flashcard(english: "Purple", german: "Lila", exampleSentence: "Die Blume ist lila."),
            Flashcard(english: "Orange", german: "Orange", exampleSentence: "Die Orange ist orange."),
            Flashcard(english: "Pink", german: "Rosa", exampleSentence: "Das Kleid ist rosa."),
            Flashcard(english: "Brown", german: "Braun", exampleSentence: "Der Tisch ist braun."),
            Flashcard(english: "Gray", german: "Grau", exampleSentence: "Die Wolken sind grau."),
            Flashcard(english: "Silver", german: "Silber", exampleSentence: "Der Ring ist aus Silber."),
            Flashcard(english: "Gold", german: "Gold", exampleSentence: "Die Uhr ist aus Gold."),
            Flashcard(english: "Light blue", german: "Hellblau", exampleSentence: "Das Hemd ist hellblau."),
            Flashcard(english: "Dark blue", german: "Dunkelblau", exampleSentence: "Die Hose ist dunkelblau."),
            Flashcard(english: "Light green", german: "Hellgrün", exampleSentence: "Das Gras ist hellgrün."),
            Flashcard(english: "Dark green", german: "Dunkelgrün", exampleSentence: "Der Wald ist dunkelgrün."),
            Flashcard(english: "Light red", german: "Hellrot", exampleSentence: "Die Rose ist hellrot."),
            Flashcard(english: "Dark red", german: "Dunkelrot", exampleSentence: "Der Wein ist dunkelrot."),
            Flashcard(english: "Turquoise", german: "Türkis", exampleSentence: "Das Meer ist türkis."),
            Flashcard(english: "Violet", german: "Violett", exampleSentence: "Die Blume ist violett.")
        ]),
        Category(name: "Numbers", icon: "number", flashcards: [
            Flashcard(english: "One", german: "Eins", exampleSentence: "Ich habe einen Hund."),
            Flashcard(english: "Two", german: "Zwei", exampleSentence: "Ich habe zwei Katzen."),
            Flashcard(english: "Three", german: "Drei", exampleSentence: "Es sind drei Uhr."),
            Flashcard(english: "Four", german: "Vier", exampleSentence: "Ich habe vier Geschwister."),
            Flashcard(english: "Five", german: "Fünf", exampleSentence: "Das Kind ist fünf Jahre alt."),
            Flashcard(english: "Six", german: "Sechs", exampleSentence: "Ich stehe um sechs Uhr auf."),
            Flashcard(english: "Seven", german: "Sieben", exampleSentence: "Es sind sieben Tage in einer Woche."),
            Flashcard(english: "Eight", german: "Acht", exampleSentence: "Das Meeting beginnt um acht Uhr."),
            Flashcard(english: "Nine", german: "Neun", exampleSentence: "Es sind neun Uhr abends."),
            Flashcard(english: "Ten", german: "Zehn", exampleSentence: "Ich habe zehn Finger."),
            Flashcard(english: "Eleven", german: "Elf", exampleSentence: "Es sind elf Uhr morgens."),
            Flashcard(english: "Twelve", german: "Zwölf", exampleSentence: "Es ist zwölf Uhr mittags."),
            Flashcard(english: "Thirteen", german: "Dreizehn", exampleSentence: "Ich bin dreizehn Jahre alt."),
            Flashcard(english: "Fourteen", german: "Vierzehn", exampleSentence: "Es sind vierzehn Tage."),
            Flashcard(english: "Fifteen", german: "Fünfzehn", exampleSentence: "Es sind fünfzehn Minuten."),
            Flashcard(english: "Sixteen", german: "Sechzehn", exampleSentence: "Ich bin sechzehn Jahre alt."),
            Flashcard(english: "Seventeen", german: "Siebzehn", exampleSentence: "Es sind siebzehn Grad."),
            Flashcard(english: "Eighteen", german: "Achtzehn", exampleSentence: "Ich bin achtzehn Jahre alt."),
            Flashcard(english: "Nineteen", german: "Neunzehn", exampleSentence: "Es sind neunzehn Euro."),
            Flashcard(english: "Twenty", german: "Zwanzig", exampleSentence: "Es sind zwanzig Personen.")
        ])
    ]
} 
