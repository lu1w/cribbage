:- ensure_loaded(deck).

%% select_hand(++Cards, -Hand, -Cribcards)
select_hand(Cards, Hand, Cribcards) :- 
    possible_hand(Cards, [], Hands), 
    deck(Deck), 
    set_difference(Deck, Cards, [], Startcards), 
    best_hand(Hands, Startcards, 0, [], Hand), 
    set_difference(Cards, Hand, [], Cribcards). 

%% possible_hand(Cards, Acc, Hands)
possible_hand([_,_,_], Hands, Hands). 
possible_hand([Card1,Card2,Card3,Card4|Cards], Acc, Hands) :- 
    Acc0 = [[Card1,Card2,Card3,Card4]|Acc], 
    possible_hand([Card1,Card2,Card3|Cards], Acc0, Acc1), 
    possible_hand([Card1,Card2,Card4|Cards], Acc1, Acc2), 
    possible_hand([Card1,Card3,Card4|Cards], Acc2, Acc3), 
    possible_hand([Card2,Card3,Card4|Cards], Acc3, Hands). 
   
%% set_difference(Set0, Set, Acc, Diff)
set_difference([], _, Diff, Diff).
set_difference([Elm|Elms], Set, Acc, Diff) :- 
    (   member(Elm, Set)
    ->  set_difference(Elms, Set, Acc, Diff)
    ;   set_difference(Elms, Set, [Elm|Acc], Diff)
    ). 

%% best_hand(Hands, Startcards, Maxi, Temp, Best)
best_hand([], _, _, Best, Best). 
best_hand([Hand|Hands], Startcards, Maxi, Temp, Best) :- 
    expected_value(Hand, Startcards, 0, Value), 
    (   Value > Maxi
    ->  best_hand(Hands, Startcards, Value, Hand, Best)
    ;   best_hand(Hands, Startcards, Maxi, Temp, Best)
    ). 

%% expected_value(Hand, Startcards, Acc, Sum)
expected_value(_, [], Value, Value). 
expected_value(Hand, [Startcard|Startcards], Acc, Sum) :- 
    hand_value(Hand, Startcard, Value), 
    Acc1 is Acc + Value, 
    expected_value(Hand, Startcards, Acc1, Sum). 