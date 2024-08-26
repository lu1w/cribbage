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

deck(Deck) :- 
    Deck = [ card(ace,hearts),card(2,hearts),card(3,hearts),card(4,hearts),
             card(5,hearts),card(6,hearts),card(7,hearts),card(8,hearts),
             card(9,hearts),card(10,hearts),
             card(jack,hearts),card(queen,hearts),card(king,hearts),
             
             card(ace,spades),card(2,spades),card(3,spades),card(4,spades),
             card(5,spades),card(6,spades),card(7,spades),card(8,spades),
             card(9,spades),card(10,spades),
             card(jack,spades),card(queen,spades),card(king,spades),
             
             card(ace,clubs),card(2,clubs),card(3,clubs),card(4,clubs),
             card(5,clubs),card(6,clubs),card(7,clubs),card(8,clubs),
             card(9,clubs),card(10,clubs),
             card(jack,clubs),card(queen,clubs),card(king,clubs),
             
             card(ace,diamonds),card(2,diamonds),card(3,diamonds),card(4,diamonds),
             card(5,diamonds),card(6,diamonds),card(7,diamonds),card(8,diamonds),
             card(9,diamonds),card(10,diamonds),
             card(jack,diamonds),card(queen,diamonds),card(king,diamonds)
           ].
   
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