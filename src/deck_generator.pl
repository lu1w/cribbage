ranked_card(Rank, Card) :-
    Card = card(Rank). 
suited_ranked_card(Suit, card(Rank), Card) :- 
    Card = card(Rank,Suit).
/*
To generate a deck, run the following query: 

maplist(ranked_card, [ace,2,3,4,5,6,7,8,9,10,jack,queen,king], Ranked_cards), 
maplist(suited_ranked_card(hearts), Ranked_cards, Cardsh), 
maplist(suited_ranked_card(spades), Ranked_cards, Cardss), 
maplist(suited_ranked_card(clubs), Ranked_cards, Cardsc), 
maplist(suited_ranked_card(diamonds), Ranked_cards, Cardsd), 
append(Cardsh, Cardss, C1), 
append(Cardsc, Cardsd, C2), 
append(C1, C2, Deck), 
print(Deck).
*/