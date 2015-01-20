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

def return_current_hand
  card_order = [1=> "a", 2=> "2", 3=> "3", 4=> "4", 5=> "5", 6=> "6", 7=> "7", 8=> "8", 9=> "9", 10=> "10", 11=> "j", 12=> "q", 13=> "k", 14=> "a"]
  cards_in_play = @cards_known
  multiples = Hash.new(0)
  @cards_known.map{|c| c[0]}.sort.each do |c|
    multiples[c] += 1
  end
  hands= Hash.new
  multiples.each do |k,v|
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
    if hands["TOAK"] && hands["P"]
      pair = hands["P"]
      toak = hands["TOAK"]
      hands.clear
      hands["FH"] = "#{toak}'s over #{pair}'s"
    end
    if hands["P2"]
      p1 = hands["P"]
      p2 = hands["P2"]
      hands.clear
      hands["TP"] = "#{p1}'s and #{p2}'s"
    end

  end

  p hands

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
request_cards_in_hand
return_probability
return_current_hand
request_cards_in_flop
return_probability
return_current_hand
request_cards_in_turn
return_probability
return_current_hand
request_cards_in_river
return_probability
return_current_hand


