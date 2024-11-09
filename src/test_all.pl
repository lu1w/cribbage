:- ensure_loaded(deck)
:- ensure_loaded(select_hand)

all_hands(Deck, Hands) :-
    possible_hand(Deck, [], Hands).
    
valid_combo(combo(Hand, Startcard), Hands, Deck) :- 
    member(Hand, Hands), 
    set_difference(Deck, Hand, Startcards), 
    member(Startcard, Startcards). 

test_combo(combo(Hand, Startcard), Outcome) :- 
    hand_value(Hand, Startcard, Value), 
    Outcome = outcome(Hand,Startcard,Value). 

run_tests(Outcomes) :- 
    deck(Deck), 
    all_hands(Deck, Hands), 
    setof(Combo, valid_card(Combo, Hands), Combos), 
    maplist(test_combo, Combos, Outcomes). 
