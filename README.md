# cribbage

2024 Sem 2 COMP30020 Project 1, the University of Melbourne, assignment grade: 95/100.

This project provides predicates that assist players in determining the scoring situation and developing strategy during the card game "Cribbage".


## Description of the Project 

The two core predicates in this project are: 
- ```hand_value/3```: evaluating the total value of hand cards of a player by summing up the points gained from each of the scoring rules (as below)
- ```select_hand/3```: determining the best 4 cards to keep for a player after given the initial 5-6 cards
    
The calculation in hand_value/3 is based on these rules: 
- +2 - each distinct combination of cards that add to 15 (A=1, J/Q/K=10)
- +2 - each dinctinct pair 
- +1 - each card in each distinct combination of runs of at least 3 cards
- +4 - all cards in hand are of the same suit
- +1 - all cards in hand and the start card are of the same suit
- +1 - hand contains the jack of th same suit as the start card 

The best hand determined by select_card/3 is based on the highest expected value (calculated using hand_value/3) of each possible hand, considering all possible startcards. 

The representation of a card in this project: ```card(Rank,Suit)```.

Rank can be either: 
- an integer between 2 to 10 inclusive 
- ace
- jack
- queen
- king. 

Suit can be either: 
- spades 
- hearts
- clubs 
- diamonds 
    
All predicate within this project assumes that any bounded card value is valid (i.e. being an instance of card/2 with valid rank and suit), so no validity checking on cards is implemented. 

The initialization of a deck is hard-coded into this project using deck/1. 

Other components and stages of Cribbage are not involved in this project. 


## Rules of the game 

Objective: be the first player to reach 121 points 

1. Dealer dealing each player 6 cards (2 players) or 5 cards (3-4 players)
2. If 3 players, dealer deals one card to a separate hand called the 'crib' or 'box'
3. Each player choose 1 or 2 cards to discard, keeping 4 and putting the discarded cards in the crib or box
4. Dealer use the 4 card hand in the crib 
5. The player preceding the dealer cuts the deck to select an extra card, called "start card" 
6. If start card is a Jack, the dealer immediately scores 2 points 
7. **{The Player}** Player take turns playing cards from their hands face up in front of them 
8. **{The Show}** Each player in turn, beginning with the player after the dealer, 
    established the value of her hand; the start card is usually considered as 
    part of each player's hand 
9. The player following the dealer collects the cards, becoming dealer for the next hand. 
10. Play proceeds this way until one player reaches 121 points.

For detailed rules of "Cribbage", please visit https://bicyclecards.com/how-to-play/cribbage.  
