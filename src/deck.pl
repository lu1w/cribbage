%% deck(?Deck)
%
%  Util predicate. 
%  Deck is unified with a list of all 52 cards within a deck of a certain order. 
deck(Deck) :- 
    ranks(Ranks), 
    suits(Suits), 
    setof(Card, valid_card(Card, Ranks, Suits), Deck).


%% ranks(?Ranks)
%
%  Util predicate. 
%  Ranks is unified with a list of all 13 ranks within a deck. 
%  For the purpose of this file, Ranks can only be of a certain order:
%      [ace,jack,queen,king,2,3,4,5,6,7,8,9,10]
%  If Ranks is passed in as a bound argument that violates this order, the 
%  predicate returns false even if the bound argument can be extend to all 13 
%  ranks of a deck in the real world. 
ranks(Ranks) :- 
    setof(Rank, between(2, 10, Rank), Rank_Nums),
    append([ace,jack,queen,king], Rank_Nums, Ranks). 


%% suits(?Suits)
%
%  Util predicate. 
%  Suits is unified with a list of all 4 suits within a deck. 
%  For the purpose of this file, Suits can only be of a certain order:
%      [spades,hearts,clubs,diamonds]
%  If Suits is passed in as a bound argument that violates this order, the 
%  predicate returns false even if the bound argument can be extend to all 4 
%  suits of a deck in the real world. 
suits([spades,hearts,clubs,diamonds]). 


%% valid_card(?Card, ?Ranks, ?Suits)
%
%  Util predicate. 
%  Card is valid if its Rank is in Ranks, and Suit is in Suits. 
valid_card(card(Rank, Suit), Ranks, Suits) :- 
    member(Rank, Ranks), 
    member(Suit, Suits). 