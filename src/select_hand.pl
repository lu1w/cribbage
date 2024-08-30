%% select_hand(++Cards, -Hand, -Cribcards)
%
%  Cards holds the 5-6 cards a player gets at the start of a Cribbage game. The
%  Hand with the highest expected value out of all possible hands is kept, and 
%  the rest of the cards go to the crib as a part of the Cribcards (which 
%  eventually becomes a part of dealer's hand). 
select_hand(Cards, Hand, Cribcards) :- 
    possible_hand(Cards, Hands), 
    deck(Deck), 
    set_difference(Deck, Cards, Startcards), 
    best_hand(Hands, Startcards, Hand), 
    set_difference(Cards, Hand, Cribcards). 


%% possible_hand(++Cards, -Hands)
% 
%  Helper predicate for select_hand/3. 
%  Cards holds the 5-6 cards a player gets at the start of a Cribbage game. All
%  possible Hands (i.e. lists of a combination of 4 cards) are generated. 
possible_hand(Cards, Hands) :- 
    possible_hand(Cards, [], Hands). 

%% possible_hand(++Cards, +Acc, -Hands)
%
%  TRO for possible_hand/2. 
%  Acc is an accumulator for Hands. 
possible_hand([_,_,_], Hands, Hands). 
possible_hand([Card1,Card2,Card3,Card4|Cards], Acc, Hands) :- 
    Acc0 = [[Card1,Card2,Card3,Card4]|Acc], 
    possible_hand([Card1,Card2,Card3|Cards], Acc0, Acc1), 
    possible_hand([Card1,Card2,Card4|Cards], Acc1, Acc2), 
    possible_hand([Card1,Card3,Card4|Cards], Acc2, Acc3), 
    possible_hand([Card2,Card3,Card4|Cards], Acc3, Hands). 


%% set_difference(++Set1, ++Set0, -Diff)
%
%  Util predicate to find the difference in two sets.  
%  Diff is a list of elements that is in Set1 but not in Set0. 
set_difference(Set1, Set0, Diff) :- 
    set_difference(Set1, Set0, [], Diff). 

%% set_difference(++Set1, ++Set0, +Acc, -Diff)
%
%  Tail recursive optimization for set_difference/2. 
%  Acc is the accumulator for Diff. 
set_difference([], _, Diff, Diff).
set_difference([X|Xs], Set0, Acc, Diff) :- 
    (   member(X, Set0)
    ->  set_difference(Xs, Set0, Acc, Diff)
    ;   set_difference(Xs, Set0, [X|Acc], Diff)
    ). 


%% best_hand(++Hands, ++Startcards, -Best)
%
%  Helper predicate for select_hand/3. 
%  Find the Best hand out of all possible Hands and all possible Startcards. 
best_hand(Hands, Startcards, Hand) :-
    Hands = [H|_], 
    best_hand(Hands, Startcards, 0, H, Hand). 

%% best_hand(++Hands, ++Startcards, +Maxi, ++Temp, -Best)
%
%  TRO for best_hand/3. 
%  Maxi is the current maximum value, and Temp being the current best hand. 
% 
%  To determine the Best hand, the value of each possible hand is calculated
%  by summing the values in the cases of each and of every possible Startcards.
%  The mean is not taken since averaging all sums by the same constant does not
%  affect the result. 
best_hand([], _, _, Best, Best). 
best_hand([Hand|Hands], Startcards, Maxi, Temp, Best) :- 
    expected_value(Hand, Startcards, Value), 
    (   Value > Maxi
    ->  best_hand(Hands, Startcards, Value, Hand, Best)
    ;   best_hand(Hands, Startcards, Maxi, Temp, Best)
    ). 


%% expected_value(++Hand, ++Startcards, -Sum)
%
%  Helper predicate for best_hand/5. 
%  Determines the Sum of the values of Hand across each and every Startcards. 
expected_value(Hand, Startcards, Value) :- 
    expected_value(Hand, Startcards, 0, Value). 

%% expected_value(++Hand, ++Startcards, +Acc, -Sum)
%
%  TRO for expected_value/3. 
%  Acc is an accumulator for adding values to Sum. 
expected_value(_, [], Value, Value). 
expected_value(Hand, [Startcard|Startcards], Acc, Sum) :- 
    hand_value(Hand, Startcard, Value), 
    Acc1 is Acc + Value, 
    expected_value(Hand, Startcards, Acc1, Sum). 