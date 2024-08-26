%% hand_value(++Hand, ++Startcard, -Value)
%
%  Based on the card in Hand and the Startcard, 
%  determined the total Value in terms of number
%  of vribbage points. 
hand_value(Hand, Startcard, Value) :- 
    length(Hand, 4),
    standardized_cards([Startcard|Hand], [], Cards), 
    msort(Cards, Cards_sorted),
    value_15s(Cards_sorted, 0, Value_15s), 
    value_pairs(Cards_sorted, [], 0, Value_pairs), 
    value_runs(Cards_sorted, 0, Value_runs),
    value_flushes(Hand, Startcard, Value_flushes), 
    value_suited_jack(Hand, Startcard, Value_jack), 
    Value is (Value_15s + Value_pairs + Value_runs + Value_flushes + Value_jack). 

%% standardized_cards(+Cards, -Cards0, -Cards1) 
%  
%  Standardize (i.e. change all the Rank to numbers) the cards in
%  Cards list, where Cards0 is an accumulator for storing the 
%  standardized card during this process, and Cards1 is all of the 
%  Cards after the standardization. 
standardized_cards([], Cards, Cards).
standardized_cards([card(Rank, Suit)|Cards], Cards0, Cards1) :- 
    (   integer(Rank)
    ->  standardized_cards(Cards, [card(Rank, Suit)|Cards0], Cards1)
    ;   Rank = ace
    ->  standardized_cards(Cards, [card(1, Suit)|Cards0], Cards1)
    ;   Rank = jack 
    ->  standardized_cards(Cards, [card(11, Suit)|Cards0], Cards1)
    ;   Rank = queen 
    ->  standardized_cards(Cards, [card(12, Suit)|Cards0], Cards1)
    ;   Rank = king 
    ->  standardized_cards(Cards, [card(13, Suit)|Cards0], Cards1)
    ). 


%% value_15s(Cards_sorted, Combinations, Value)
value_15s([], Combinations, Value) :- 
    Value is (2 * Combinations). 
value_15s([card(Rank, _)|Cards_sorted], Combinations0, Value) :- 
    (  Rank > 10
    -> count_15s(Cards_sorted, 10, 0, Combinations)
    ;  count_15s(Cards_sorted, Rank, 0, Combinations)
    ), 
    Combinations1 is Combinations0 + Combinations, 
    value_15s(Cards_sorted, Combinations1, Value). 

%% count_15s(Cards_sorted, Sum, Acc, Combinations)
% 
%  Counts the number of combinations that sum up to 15 
%  with Sum storing the current sum of the combination. 
count_15s([], _, Combinations, Combinations). 
count_15s([card(Rank, _)|Cards_sorted], Sum, Acc, Combinations) :- 
    Rank_value is min(10, Rank), 
    % Including the first card 
    (   Rank_value + Sum > 15
    ->  Combinations1 = 0
    ;   Rank_value + Sum =:= 15 
    ->  Combinations1 = 1
    ;   Sum1 is Rank_value + Sum, 
        count_15s(Cards_sorted, Sum1, 0, Combinations1)
    ), 
    Acc1 is Acc + Combinations1, 
    % Not including the first card 
    count_15s(Cards_sorted, Sum, Acc1, Combinations).
    %%Combinations is Combinations1 + Combinations2.


%% value_pairs(Cards_sorted, Checked, Acc, Value)
value_pairs([], _, Value, Value). 
value_pairs([card(Rank, _)|Cards], Checked, Acc, Value) :-  
    (   member(Rank, Checked)
    ->  value_pairs(Cards, Checked, Acc, Value)
    ;   count_matches(Cards, Rank, 0, Matches),
        (   Matches = 1
        ->  Acc1 is Acc + 2
        ;   Matches = 2
        ->  Acc1 is Acc + 6
        ;   Matches = 3
        ->  Acc1 is Acc + 12
        ;   Acc1 = Acc
        ), 
        Checked1 = [Rank|Checked],    
        value_pairs(Cards, Checked1, Acc1, Value)
    ).   

%% count_matches(Cards, Target, Acc, Matches)
count_matches([], _, Matches, Matches). 
count_matches([card(Rank0, _)|Cards], Rank, Acc, Matches) :-
    (   Rank0 = Rank 
    ->  Acc1 is Acc + 1, 
        count_matches(Cards, Rank, Acc1, Matches)
    ;   Acc = Matches
    ). 
    
    
%% value_runs(Cards_sorted, Acc, Value)
value_runs([], Value, Value). 
value_runs([Card|Cards_sorted], Acc, Value) :- 
    count_runs(Cards_sorted, Card, 1, 1, 1, Points, Rest),
    Acc1 is Acc + Points, 
    value_runs(Rest, Acc1, Value). 

%% count_runs(Cards, Prev, Consec, Duplicates, Multiple, Points)
count_runs([], _, Consec, Duplicates, Multiple, Points, []) :- 
    Multiple1 is Multiple * Duplicates, 
    run_points(Consec, Multiple1, Points). 
count_runs([card(Rank0, _)|Cards_sorted], card(Rank, _), Consec, Duplicates, Multiple, Points, Rest) :- 
    (   Rank + 1 < Rank0
    ->  Rest = [card(Rank0, _)|Cards_sorted],
        Multiple1 is Multiple * Duplicates, 
        run_points(Consec, Multiple1, Points)
    ;   Rank + 1 =:= Rank0
    ->  Consec1 is Consec + 1,
        Multiple1 is Multiple * Duplicates, 
        count_runs(Cards_sorted, card(Rank0, _), Consec1, 1, Multiple1, Points, Rest)
    ;   Rank = Rank0 % duplicate cards 
    ->  Duplicates1 is Duplicates + 1, 
        count_runs(Cards_sorted, card(Rank0, _), Consec, Duplicates1, Multiple, Points, Rest)
    ). 
    %;   throw(error(domain_error(,Rank0), 
    %                context(count_runs/5, "Cards list not properly sorted"))).
    
run_points(Consec, Multiple, Points) :- 
    (  Consec >= 3
    -> Points is Multiple * Consec
    ;  Points = 0
    ). 

    
%% value_flushes(Hand, Startcard, Value)
value_flushes(Hand, card(_, Suit0), Value) :- 
    (   all_suit(Hand, Suit0)
    ->  Value = 5
    ;   all_suit(Hand, _)
    ->  Value = 4
    ;   Value = 0
    ).

%% all_suit(+Hand, ?Suit)
all_suit([card(_, Suit), card(_, Suit), card(_, Suit), card(_, Suit)], Suit).  


%% value_suited_jack(Hand, Startcard, Value)
value_suited_jack(Hand, card(_, Suit), Value) :-
    (  member(card(jack, Suit), Hand)
    -> Value = 1
    ;  Value = 0
    ).
    
    