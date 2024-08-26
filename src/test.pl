:- ensure_loaded(cribbage).

%% ===== TESTING ONLY ===== 
% ace, jack, queen, or king
% clubs, diamonds, hearts, or spades

validate_cards([]).
validate_cards([card(Rank, Suit)|Cards]) :- 
    member(Rank, [ace,2,3,4,5,6,7,8,9,10,jack,queen,king]), 
    member(Suit, [clubs,diamonds,hearts,spades]),
    validate_cards(Cards). 

% ---------- hand_value() -------------

/* Test 1-1 */
hand1(H, S, V) :- 
    H = [card(7,clubs), card(queen,hearts), card(2,clubs), card(jack,clubs)], 
    S = card(9,hearts), 
    V = 0. 

/* Test 1-2 
    - a pair, king (2 points)
*/
hand2(H, S, V) :-
    H = [card(7,hearts), card(ace,spades), card(king,hearts), card(3,hearts)],
    S = card(king,spades),
    V = 2. 

/* Test 1-3
    - one 15s, 2+3+K (2 points)
    - one run, A-2-3 (3 points)   
*/
hand3(H, S, V) :- 
    H = [card(ace,spades), card(king,hearts), card(3,hearts), card(7,hearts)],
    S = card(2,diamonds),
    V = 5. 

/* Test 1-4
    - three 15s, 6c+9c, 7c+8c, 7c+8s (3 * 2 = 6 points)
    - one pair, 8 (2 points)
    - two 4-runs, 6c-7c-8c-9c, 6c-7c-8s-9c (2 * 4 = 8 points)
    - one flush, 6c-7c-8c-9c, (4 points)   
*/
hand4(H, S, V) :- 
    H = [card(6,clubs), card(7,clubs), card(8,clubs), card(9,clubs)],
    S = card(8,spades),
    V = 20. 

/* Test 1-5
    - four 15s, 7c+8c, 7c+8h, 7h+8c, 7h+8h (4 * 2 = 8 points)
    - two pairs, 7, 8 (2 * 2 = 4 points)
    - four 3-runs, 7c-8c-9s, 7c-8h-9s, 7h-8c-9s, 7h-8h-9s (4 * 3 = 12 points)  
*/
hand5(H, S, V) :- 
    H = [card(7,clubs), card(7,hearts), card(8,clubs), card(9,spades)],
    S = card(8,hearts),
    V = 24. 

/* Test 1-6
    - eight 15s, 5+jack * 4, 5+5+5 * 4 (8 * 2 = 16 points)
    - six pairs, 5-four-of-a-kind (12 points)
    - one of hits nod, jack-diamonds, (1 points) 
*/
hand6(H, S, V) :- 
    H = [card(5,clubs), card(5,hearts), card(jack,diamonds), card(5,spades)],
    S = card(5,diamonds),
    V = 29. 

%% Standardize then sort cards 
stdsrt(H, S, Cards_sorted) :-
    %validate_cards([S|H]),
    standardized_cards([S|H], [], Cards_std),
    msort(Cards_std, Cards_sorted).

%% test 15s valuation 
% e.g. test1(H,S,V), test_15s(H,S,Value).
test_15s(H, S, Value) :- 
    stdsrt(H, S, Cards_sorted),
    value_15s(Cards_sorted, 0, Value).

%% test pair valuation 
% e.g. test1(H,S,V), test_pairs(H,S,Value).
test_pairs(H, S, Value) :- 
    stdsrt(H, S, Cards_sorted),
    value_pairs(Cards_sorted, [], 0, Value).

%% test runs valuation 
test_runs(H, S, Value) :- 
    stdsrt(H, S, Cards_sorted),
    value_runs(Cards_sorted, 0, Value). 

%% test flushes valuation 
test_flushes(H, S, Value) :- 
    value_flushes(H, S, Value). 

%% test "one for his nod" valuation 
test_suited_jack(H, S, Value) :- 
    value_suited_jack(H, S, Value). 


% ---------- select_hand() -------------

cards51(Cards) :- 
    Cards = [card(7,clubs), card(queen,hearts), card(2,clubs), card(jack,clubs), card(9,diamonds)]. 

cards52(Cards) :- 
    Cards = [card(7,hearts), card(ace,spades), card(king,hearts), card(3,hearts), card(3,diamonds)]. 

cards53(Cards) :- 
    Cards = [card(7,clubs), card(2,clubs), card(4,clubs), card(3,hearts), card(6,clubs)]. 

test_set_diff(Set0, Set1, Diff) :- 
    set_difference(Set0, Set1, [], Diff). 
