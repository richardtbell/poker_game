# Next step is to get it to return only the 5 best hands that are possible from the community
# Then find the hands that will beat your hand
# Set up test suite
# Change hashes so they have consistent keys

class Probabilities

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
    all_cards = ["c", "d", "h", "s"].map do |suit|
      num.map {|number| "#{number}#{suit}"}
    end
    all_cards.flatten!
  end

  def deck_cards_remaining_after(cards)
    remaining_cards = all_cards - cards
  end

  def possible_pockets(remaining_cards)
    possible_pockets = remaining_cards.map do |a|
      remaining_cards.map {|b| [a,b] unless a == b}
    end
    possible_pockets.flatten!(1).compact!
  end

  def all_possible_hands(remaining_cards, community_cards)
    all_possible_hands = []
    #########################################
    p possible_pockets(remaining_cards)[8...9]
    possible_pockets(remaining_cards)[8...9].each do |a|
      all_possible_hands.push(return_best_hand(a + community_cards))
    end
    #########################################
    p all_possible_hands.uniq
    return all_possible_hands
  end

  def return_possible_hands_based_on_community_cards(cards)
    remaining_cards = deck_cards_remaining_after(cards)
    community_cards = cards[2..-1]
    community_hand = return_best_hand(community_cards)
    all_possible_hands = all_possible_hands(remaining_cards, community_cards)
    unique_hands = all_possible_hands.uniq
    ranked_hands = rank_all_possible_hands(unique_hands)
    community_hand_index = ranked_hands.index(community_hand)
    ranked_hands = ranked_hands.slice!(community_hand_index)
    return ranked_hands
  end

  def rank_all_possible_hands(hands)
    newhands = hands.sort_by { |a| hand_score(a.keys.first) }
  end

  def rank_hands(hands)
    Hash[hands.sort_by{ |a| hand_score(a[0]) }]
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

  def array_increments?(array)
    sorted = array.sort
    lastNum = sorted[0]
    sorted[1, sorted.count].each do |n|
      if lastNum + 1 != n
        return false
      end
      lastNum = n
    end
    true
  end

  def straight(cards) #take_while or drop_while
    #########################################
    # Fix case when there is a straight and a pair
    p "straight"
    p cards
    #########################################
    sorted_cards = sort_cards(cards)
    indexed_cards = sorted_cards.map{|c| card_score(c)}
    indexed_cards = indexed_cards.push(13) if cards_contain_ace(cards)
    n = 0
    straight = false
    while n <= indexed_cards.length - 5
      hand = indexed_cards[n...n+5]
      if array_increments?(hand)
        straight = (n...n+5).to_a
        break
      end
      n += 1
    end
    if straight
      straight.map! do |c|
        sorted_cards[c] || sorted_cards[0]
      end
    end
    p straight
    return straight
  end

  def straight_flush(cards, suit)
    flush_cards = cards.select{|c| c if c[-1] == suit }
    straight(flush_cards)
  end

  def royal_flush(cards, suit)
    flush_cards = cards.select{|c| c if c[-1] == suit }
    straight_flush_cards = straight(flush_cards)
    if straight_flush_cards[-1][0...-1] == "10" && straight(flush_cards)[0][0...-1] == "a"
      royal_flush_cards = straight_flush_cards
    end
    royal_flush_cards
  end



  def return_best_hand(cards)
    #########################################
    p cards
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

   ############################################################################
   # Need to find straight before the hand is ranked
    hands = rank_hands(hands)
   ############################################################################

    if hands["F"]
      suit = hands["F"]
      hands.clear
      hands["F"] = suit
      straight_flush = straight_flush(cards, suit)
      if straight_flush
        royal_flush = royal_flush(cards,suit)
        hands.clear
        if royal_flush
          hands["RF"] = "#{straight_flush[-1]} through #{straight_flush[0]}"
        else
          hands["SF"] = "#{straight_flush[-1]} through #{straight_flush[0]}"
        end
      end
    elsif straight(cards)
      straight = straight(cards)
      hands.clear
      hands["S"] = "#{straight[-1][0...-1]} through #{straight[0][0...-1]}"
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
    hands = Hash[*hands.first]
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
end
