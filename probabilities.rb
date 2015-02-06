@cards_known = []
def request_cards_in_hand
  input = ""
  2.times do
    print "Your cards: "
    input = gets.chomp
    @cards_known << input
  end
end

def request_cards_in_flop
  3.times do
    print "The Flop cards: "
    input = gets.chomp
    @cards_known << input
  end
end

def request_cards_in_turn
  print "The Turn cards: "
  input = gets.chomp
  @cards_known << input
end

def request_cards_in_river
  print "The River cards: "
  input = gets.chomp
  @cards_known << input
end

def all_cards
  num = (Array (2..10)) + ["j", "q", "k", "a"]
  all_cards = ["c", "d", "h", "s"].map do |s|
    num.map {|a| "#{a}#{s}"}
  end
  all_cards.flatten!
end

def return_possible_hands_based_on_community_cards
  remaining_cards = all_cards - @cards_known
  community_cards = @cards_known[2..-1]

  possible_pockets = remaining_cards.map do |a|
    remaining_cards.map {|b| [a,b] unless a == b}
  end
  possible_pockets.flatten!(1).compact!
  all_possible_hands = []
  possible_pockets.each do |a|
    all_possible_hands.push(return_hands(a + community_cards))
  end
  return all_possible_hands.uniq
end


  # card_order = [1=> "a", 2=> "2", 3=> "3", 4=> "4", 5=> "5", 6=> "6", 7=> "7", 8=> "8", 9=> "9", 10=> "10", 11=> "j", 12=> "q", 13=> "k", 14=> "a"]
def card_score(card)
  %w(a k q j 10 9 8 7 6 5 4 3 2).index(card[0].chr)
end

def hand_score(hand)
  %w(RF SF FOAK FH F S TOAK TP P P2 P3).index(hand)
end
# @cards_known = ["5s","ad", "ac", "2s", "2c", "3d", "3c"]
def return_hands(cards_known)
  cards_in_play = cards_known
  multiples = Hash.new(0)
  cards_known.map{|c| c[0]}.sort{ |a,b| card_score(a) <=> card_score(b)}.each do |c|
    multiples[c] += 1
  end
  hands= Hash.new
  multiples.each do |k,v| #select will do this without using each
    hands["FOAK"] = k if v == 4
    hands["TOAK"] = k if v == 3
    if v == 2
      if hands["P"]
        if hands["P2"]
          hands["P3"] = k
        end
        hands["P2"] = k
      else
        hands["P"] = k
      end
    end
  end
  hands = Hash[hands.sort{ |a,b| hand_score(a[0]) <=> hand_score(b[0])}]
  if hands["TOAK"] && hands["P"]
    pair = hands["P"]
    toak = hands["TOAK"]
    hands.clear
    hands["FH"] = "#{toak}'s over #{pair}'s"
  elsif hands["P2"]
    p1 = hands["P"]
    p2 = hands["P2"]
    hands.clear
    hands["TP"] = "#{p1}'s and #{p2}'s"
  end
  return hands
end


def return_probability
  total_cards_known = @cards_known.count
  total_cards_unknown = 52.0 - total_cards_known
  numbers_played = Hash.new(0)
  @cards_known.map{|c| c[0]}.sort.each do |c|
    numbers_played[c] += 1
  end
  suits_played = Hash.new(0)
  @cards_known.map{|c| c[1]}.sort.each do |c|
    suits_played[c] += 1
  end
  cards_of_each_suit = {"c"=>13, "d"=>13, "h"=>13, "s"=>13}
  cards_left_of_each_suit = cards_of_each_suit.merge(suits_played){|k, v, w| v - w}
  highest_flush_suit = suits_played.max[0]
  number_of_highest_flush_suit = suits_played.max[1]
  prob_of_flush = cards_left_of_each_suit.merge(cards_left_of_each_suit){|k,v,w| v/total_cards_unknown * (v-1)/(total_cards_unknown-1) *(v-2)/(total_cards_unknown-2)}
end
# request_cards_in_hand
# return_probability
# return_hands(@cards_known)
# request_cards_in_flop
# return_possible_hands_based_on_community_cards
# return_probability
# return_hands(@cards_known)
# request_cards_in_turn
# return_probability
# return_hands(@cards_known)
# request_cards_in_river
# return_probability
# return_hands(@cards_known)

@cards_known = ["2d","ad", "ac", "2s", "2c", "3d", "3c"]
p "return_hands"
p return_hands(@cards_known)
# p "return_probability"
# p return_probability
# p "return_possible_hands_based_on_community_cards"
# p return_possible_hands_based_on_community_cards

