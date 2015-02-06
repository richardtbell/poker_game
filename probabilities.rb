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

def card_score(card)
  %w(a k q j 10 9 8 7 6 5 4 3 2).index(card[0...-1])
end

def hand_score(hand)
  %w(RF SF FOAK FH F S TOAK TP P P2 P3 HC).index(hand)
end

def sort_cards(cards)
  cards.sort{ |a,b| card_score(a) <=> card_score(b)}
end


def multiples(cards)
  multiples = Hash.new(0)
  sort_cards(cards).map{|c| c[0...-1]}.each do |c|
    multiples[c] += 1
  end
  multiples
end

def suits(cards)
  suits = Hash.new(0)
  cards.map{|c| c[-1]}.each do |c|
    suits[c] += 1
  end
  suits.sort
end

def cards_contain_ace(cards)
  !cards.select{|c| c[0]=="a"}.empty?
end

def straight(cards) #take_while or drop_while
  sorted_cards = sort_cards(cards)
  indexed_cards = sorted_cards.map{|c| card_score(c)}
  indexed_cards = indexed_cards.push(13) if cards_contain_ace(cards)
  cards_in_a_row = []
  indexed_cards.each_with_index do |v,i|
    if i > 0
      cards_in_a_row.push(i-1) if (v - indexed_cards[i-1]) == 1
      if i == (indexed_cards.length - 1)
        cards_in_a_row.push(i) if (v - indexed_cards[i-1]) == 1
      end
    end
  end
  cards_in_a_row.map! do |c|
    sorted_cards[c] || sorted_cards[0]
  end
  if cards_in_a_row.length >= 5
    first_card = cards_in_a_row.last
    last_card = cards_in_a_row.first
  end
  [first_card, last_card]
end

def straight_flush(cards, suit)
  flush_cards = cards.select{|c| c if c[-1] == suit }
  straight(flush_cards)
end

def royal_flush(cards, suit)
  flush_cards = cards.select{|c| c if c[-1] == suit }
  straight_flush_cards = straight(flush_cards)
  if straight_flush_cards[0][0...-1] == "10" && straight(flush_cards)[1][0...-1] == "a"
    royal_flush_cards = straight_flush_cards
  end
  royal_flush_cards
end

def return_hands(cards)
  cards_in_play = cards
  hands= Hash.new
  multiples(cards).each do |k,v| #select will do this without using each
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
  suits(cards).each do |k,v|
    hands["F"] = k if v == 5
  end

  hands = Hash[hands.sort{ |a,b| hand_score(a[0]) <=> hand_score(b[0])}]
  if hands["F"]
    suit = hands["F"]
    hands.clear
    hands["F"] = suit
    straight_flush = straight_flush(cards, suit)
    if !straight_flush.first.nil? && !straight_flush.last.nil?
      royal_flush = royal_flush(cards,suit)
      hands.clear
      if royal_flush && !royal_flush.first.nil? && !royal_flush.last.nil?
        hands["RF"] = "#{straight_flush[0]} through #{straight_flush[1]}"
      else
        hands["SF"] = "#{straight_flush[0]} through #{straight_flush[1]}"
      end
    end
  elsif !straight(cards).first.nil? && !straight(cards).last.nil?
    straight = straight(cards)
    hands.clear
    hands["S"] = "#{straight[0][0]} through #{straight[1][0]}"
  elsif hands["TOAK"] && hands["P"]
    pair = hands["P"]
    toak = hands["TOAK"]
    hands.clear
    hands["FH"] = "#{toak}'s over #{pair}'s"
  elsif hands["P2"]
    p1 = hands["P"]
    p2 = hands["P2"]
    hands.clear
    hands["TP"] = "#{p1}'s and #{p2}'s"
  else
    hands["HC"] = sort_cards(cards)[0]
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
p "high card"
@cards_known = ["9h","3d", "ac", "7d", "2c", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "pair"
@cards_known = ["4h","4d", "ac", "7d", "2c", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "two pair"
@cards_known = ["4h","4d", "ac", "ad", "2c", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "three of a kind"
@cards_known = ["4h","4d", "4c", "7d", "2c", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "full house"
@cards_known = ["4h","4d", "4c", "7d", "7c", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "four of a kind"
@cards_known = ["4h","4d", "4c", "4s", "2c", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "straight"
@cards_known = ["4h","3d", "ac", "7d", "2c", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "flush"
@cards_known = ["4h","3h", "ah", "7h", "2c", "jh", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)


p "straight flush"
@cards_known = ["4h","5h", "3h", "ah", "2h", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

p "royal flush"
@cards_known = ["10h","jh", "qh", "ah", "kh", "jd", "5d"]
p sort_cards(@cards_known)
p return_hands(@cards_known)

# p "return_probability"
# p return_probability
# p "return_possible_hands_based_on_community_cards"
# p return_possible_hands_based_on_community_cards

