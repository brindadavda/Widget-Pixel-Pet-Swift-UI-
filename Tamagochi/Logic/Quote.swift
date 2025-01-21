//
//  Quote.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation

// struct, that represents quote
struct Quote {
    
    // MARK: - Properties
    
    let text: String
    let author: String
    
    // MARK: - Methods
    
    static func getQuotes() -> [Quote] {
        let quotes = [
            Quote(text: "Learn the rules like a pro, so you can break them like an artist.", author: "Pablo Picasso"),
            Quote(text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt"),
            Quote(text: "Success is not final, failure is not fatal: It is the courage to continue that counts.", author: "Winston Churchill"),
            Quote(text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela"),
            Quote(text: "In three words I can sum up everything I've learned about life: it goes on.", author: "Robert Frost"),
            Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
            Quote(text: "To be yourself in a world that is constantly trying to make you something else is the greatest accomplishment.", author: "Ralph Waldo Emerson"),
            Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
            Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
            Quote(text: "Do not go where the path may lead, go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson"),
            Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
            Quote(text: "The only person you are destined to become is the person you decide to be.", author: "Ralph Waldo Emerson"),
            Quote(text: "Life is 10% what happens to us and 90% how we react to it.", author: "Charles R. Swindoll"),
            Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
            Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky"),
            Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
            Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
            Quote(text: "The only thing necessary for the triumph of evil is for good men to do nothing.", author: "Edmund Burke"),
            Quote(text: "The only true wisdom is in knowing you know nothing.", author: "Socrates"),
            Quote(text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein"),
            Quote(text: "Life isn't about waiting for the storm to pass, it's about learning how to dance in the rain.", author: "Vivian Greene"),
            Quote(text: "You must be the change you wish to see in the world.", author: "Mahatma Gandhi"),
            Quote(text: "Twenty years from now you will be more disappointed by the things that you didn't do than by the ones you did do.", author: "Mark Twain"),
            Quote(text: "To live is the rarest thing in the world. Most people exist, that is all.", author: "Oscar Wilde"),
            Quote(text: "Our greatest weakness lies in giving up. The most certain way to succeed is always to try just one more time.", author: "Thomas A. Edison"),
            Quote(text: "Don't cry because it's over, smile because it happened.", author: "Dr. Seuss"),
            Quote(text: "The only limit to our realization of tomorrow will be our doubts of today.", author: "Franklin D. Roosevelt"),
            Quote(text: "You can't use up creativity. The more you use, the more you have.", author: "Maya Angelou"),
            Quote(text: "The journey of a thousand miles begins with one step.", author: "Lao Tzu"),
            Quote(text: "A person who never made a mistake never tried anything new.", author: "Albert Einstein"),
            // Add more quotes here...
        ]
        return quotes
    }
    
}
