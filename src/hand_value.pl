%% hand_value(++Hand, ++Startcard, -Value)
%
%  Based on the 4 cards in Hand and the Startcard, determined the total Value 
%  of points the Hand worth in Cribbage. If Hand does not contain exactly 4 
%  cards, the predicate will fail. 
hand_value(Hand, Startcard, Value) :- 
    length(Hand, 4),
    standardize_cards([Startcard|Hand], [], Cards), 
    msort(Cards, Cards_Sorted),
    value_15s(Cards_Sorted, Value_15s), 
    value_pairs(Cards_Sorted, Value_Pairs), 
    value_runs(Cards_Sorted, Value_Runs),
    value_flushes(Hand, Startcard, Value_Flushes), 
    value_suited_jack(Hand, Startcard, Value_Jack), 
    Value is Value_15s + Value_Pairs + Value_Runs + Value_Flushes + Value_Jack. 


%% standardized_cards(++Cards, +Acc, -Cards_Std) 
%  
%  Standardize (i.e. consolidate all the Rank to numbers) each and every card 
%  in Cards, where Acc is an accumulator for storing the standardized cards 
%  during this process, and Cards_Std unifies with the list of cards after 
%  standardization. 
standardize_cards([], Cards_Std, Cards_Std).
standardize_cards([card(Rank,Suit)|Cards], Acc, Cards_Std) :- 
    standardize_card(card(Rank,Suit), Card_Std),
    standardize_cards(Cards, [Card_Std|Acc], Cards_Std).

%% standardize_card(++Card, -Card_Std)
% 
%  Helper predicate for standardized_cards/3. 
standardize_card(card(ace,Suit), card(1,Suit)).
standardize_card(card(jack,Suit), card(11,Suit)).
standardize_card(card(queen,Suit), card(12,Suit)).
standardize_card(card(king,Suit), card(13,Suit)).
standardize_card(card(Rank,Suit), card(Rank,Suit)) :- integer(Rank). 


%% value_15s(++Cards_Sorted, -Value)
%  
%  Cards_Sorted is a list of cards sorted based on the rank; 
%  Value is the total points scored from 15s in Cards_Sorted, which equals to 
%  the product of the number of combinations that sum up to 15 and the points 
%  for each combination (i.e. 2 points). 
value_15s(Cards_Sorted, Value) :- 
    count_15s(Cards_Sorted, 0, 0, Combinations), 
    Value is Combinations * 2. 

%% count_15s(++Cards_Sorted, +Sum, +Acc, -Combinations)
% 
%  Helper predicate for value_15s/2, where: Combinations is the number of cards 
%  combinations in Cards_Sorted; Sum is an accumulator for the sum of ranks in 
%  the current combination; and Acc is the accumulator for Combination. 
%
%  The implementation uses a "tree-expansion" approach. At each call to the
%  predicate, two recursive call is performed based on these two cases: 
%      1) the head card in Cards_Sorted is included in the combination;
%      2) the head card in Cards_Sorted is not included in the combination.
%  Thus by summing up the Combinations from all the "nodes" generated by the 
%  recursive calls, the total number of combinations are found.  
count_15s([], _, Combinations, Combinations). 
count_15s([card(Rank,_)|Cards_Sorted], Sum, Acc, Combinations) :- 
    Rank_value is min(10, Rank), 
    % Case (1) in the documentation 
    (   Rank_value + Sum > 15
    ->  Combinations1 = 0
    ;   Rank_value + Sum =:= 15 
    ->  Combinations1 = 1
    ;   Sum1 is Rank_value + Sum, 
        count_15s(Cards_Sorted, Sum1, 0, Combinations1)
    ), 
    % Update Case (1) result in the accumator to achieve TRO 
    Acc1 is Acc + Combinations1, 
    % Case (2) in the documentation 
    count_15s(Cards_Sorted, Sum, Acc1, Combinations).


%% value_pairs(++Cards_Sorted, -Value)
%
%  Cards_Sorted is a list of cards sorted based on the rank; 
%  Value is the total points scored from pairs in Cards_Sorted, which equals to 
%  the product of the number of distinct pairs and the points for each pair 
%  (i.e. 2 points). 
value_pairs(Cards_Sorted, Value) :-  
    count_pairs(Cards_Sorted, 0, Pairs), 
    Value is Pairs * 2. 

%% count_pairs(++Cards_Sorted, +Acc, -Pairs)
%
%  Helper predicate for value_pairs/2. 
%  Count the number of distinct pairs in Cards_Sorted by recursively calling 
%  counting the number of matching cards for each card, then unify the count
%  with Pairs. Acc is an accumulator for Pairs. 
count_pairs([], Pairs, Pairs). 
count_pairs([card(Rank,_)|Cards], Acc, Pairs) :- 
    count_matches(Cards, Rank, 0, Matches),
    Acc1 is Acc + Matches,
    count_pairs(Cards, Acc1, Pairs). 
    
%% count_matches(++Cards_Sorted, +Rank, +Acc, -Matches)
% 
%  Helper predicate for count_pairs/3. 
%  Recursively calls itself to check if the next card Rank0 in Cards_Sorted
%  matches the targer Rank, and stop when an inequality occurs (since the 
%  cards are sorted). The number of matches is unified with Matches, with Acc
%  being the accumulator for Matches. 
count_matches([], _, Matches, Matches). 
count_matches([card(Rank0,_)|Cards_Sorted], Rank, Acc, Matches) :-
    (   Rank0 = Rank 
    ->  Acc1 is Acc + 1, 
        count_matches(Cards_Sorted, Rank, Acc1, Matches)
    ;   Acc = Matches 
    ). 
    

%% value_runs(++Cards_Sorted, -Value)
%
%  Cards_Sorted is a list of cards sorted based on the rank; 
%  Value is the total points scored from runs in Cards_Sorted, which equals to 
%  the number of points gained per concecutive group of cards. 
value_runs(Cards_Sorted, Value) :- 
    value_runs(Cards_Sorted, 0, Value). 

%% value_runs(++Cards_Sorted, +Acc, -Value)
% 
%  Helper predicate for value_runs/3. 
%  Acc is the accumulator for Value, which accumulates the points for each 
%  concecutive group. If a concecutive group is not scoring any points (i.e. 
%  less than 3 cards in the group), then no points are added to the accumulator 
%  Acc duringthat recursive call. 
value_runs([], Value, Value). 
value_runs([Card|Cards_Sorted], Acc, Value) :- 
    count_runs(Cards_Sorted, Card, 1, 1, 1, Points, Rest),
    Acc1 is Acc + Points, 
    value_runs(Rest, Acc1, Value). 

%% count_runs(++Cards_Sorted, ++Prev, +Consec, +Duplicates, +Multiple, 
%             -Points, -Rest)
%
%  Helper predicate for value_runs/3. 
%  Count the number of runs in Cards_Sorted, and unify the number of points 
%  scored from the runs with Points. Prev is the previous card, which is used
%  as a reference to check if the next card has a consecutive rank. Consec acts 
%  like an accumulator for counting the number of consecutive cards in the 
%  current group. Rest is the list of cards that have not yet been checked and 
%  their rank cannot be reached by linking consecutive ranks from Prev, helps
%  value_runs/3 to skip the cards that're already searched during the each 
%  recursion. 
%  
%  The approach here to search for runs is based on a linear scan over all
%  the cards within Cards_Sorted, and updates on key parameters for calculating  
%  Points as we recursively search through the cards.  
%  The parameters involved in the calculation are:
%      - Duplicates: the number of duplications of the current card rank 
%      - Multiple: the number that needs to be multiplied to the number of  
%        consecutive cards when reaching a base case, due to duplicating cards
%  The updates is dependent on the type of relationship between Prev card Rank
%  and next card's Rank0; there are 3 cases: 
%      1) Not consecutive (base case) - the current consecutive group 
%         terminates, Points calculated based on the current Consec, 
%         Duplicates, and Multiple 
%      2) Consecutive - increment Consec, update Multiple (by multipling the 
%         number of duplicate of the rank), and reinitialize Duplicate count; 
%         then use the updated parameters to recursively fold over to the next 
%         card in Cards_Sorted. 
%      3) Identical - increment Duplicates and fold over to the next card; the 
%         effects of the duplication on the final Points will be dealed with in 
%         case (1) and case (2). 
count_runs([], _, Consec, Duplicates, Multiple, Points, []) :- 
    Multiple1 is Multiple * Duplicates, 
    runs_points(Consec, Multiple1, Points). 
count_runs([card(Rank0,_)|Cards_Sorted], card(Rank,_), 
           Consec, Duplicates, Multiple, Points, Rest) :- 
    (   Rank + 1 < Rank0 % Case (1)
    ->  Rest = [card(Rank0,_)|Cards_Sorted],
        Multiple1 is Multiple * Duplicates, 
        runs_points(Consec, Multiple1, Points)
    ;   Rank + 1 =:= Rank0 % Case (2)
    ->  Consec1 is Consec + 1,
        Multiple1 is Multiple * Duplicates, 
        count_runs(Cards_Sorted, card(Rank0,_), 
                   Consec1, 1, Multiple1, Points, Rest)
    ;   Rank = Rank0 % Case (3)
    ->  Duplicates1 is Duplicates + 1, 
        count_runs(Cards_Sorted, card(Rank0,_), 
                   Consec, Duplicates1, Multiple, Points, Rest)
    ). 

%% runs_points(+Consec, +Multiple, -Points)
% 
%  Helper predicate for count_runs/6. 
%  Based on Consec (i.e. the number of consecutive cards) and the Multiple 
%  calculated based on the duplicates cards, the total number of points for 
%  runs is calculated and unified with Points. 
%  Points can be 0 if there are less than 3 consecutive cards.
runs_points(Consec, Multiple, Points) :- 
    (   Consec >= 3
    ->  Points is Multiple * Consec
    ;   Points = 0
    ). 

    
%% value_flushes(++Hand, ++Startcard, -Value)
%
%  Hand is a list of 4 cards. Startcard is a card that represent the startcard
%  of a Cribbage game. Value is the total points scored from flushes based on
%  Hand and Startcard. 
value_flushes(Hand, card(_,Suit0), Value) :- 
    (   Hand = [card(_,Suit0), card(_,Suit0), card(_,Suit0), card(_,Suit0)]
    ->  Value = 5
    ;   Hand = [card(_,Suit), card(_,Suit), card(_,Suit), card(_,Suit)]
    ->  Value = 4
    ;   Value = 0
    ).


%% value_suited_jack(++Hand, ++Startcard, -Value)
%
%  Hand is a list of 4 cards. Startcard is a card that represent the startcard
%  of a Cribbage game. Value is 1 if Hand contains a jack of the same rank as 
%  the Startcatd, as the rules of Cribbage says. 
value_suited_jack(Hand, card(_,Suit), Value) :-
    (   member(card(jack,Suit), Hand)
    ->  Value = 1
    ;   Value = 0
    ).