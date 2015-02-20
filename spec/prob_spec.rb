require 'spec_helper'

RSpec.describe Probabilities do
  before(:each) do
    @probabilities = Probabilities.new
  end

  describe "#all_cards" do
    it "should return all the cards" do
      expect(@probabilities.all_cards.length).to eq(52)
    end
  end

  describe "#deck_cards_remaining_after" do
    it "should return all the remaining cards" do
      remaining_cards = @probabilities.deck_cards_remaining_after([{number: 2, suit: :clubs}])
      expect(remaining_cards.length).to eq(51)
      expect(remaining_cards).to_not include({number: 2, suit: :clubs})
    end
  end

  describe "#possible_pockets" do
    it "should return all the possible_pockets cards" do
      remaining_cards = [{number:2, suit: :clubs}, {number:3, suit: :clubs} ]
      possible_pockets = @probabilities.possible_pockets(remaining_cards)
      expect(possible_pockets.length).to eq(1)
      expect(possible_pockets).to eq([[{number:2, suit: :clubs}, {number:3, suit: :clubs} ]])
    end
  end

  describe "#add_card_score" do
    it "should return the correct score for a two" do
      card = {number:2, suit: :clubs}
      expect(@probabilities.add_card_score(card)).to eq({number:2, suit: :clubs, score: 12})
    end

    it "should return the correct score for an ace" do
      card = {number: :ace, suit: :clubs}
      expect(@probabilities.add_card_score(card)).to eq({number: :ace, suit: :clubs, score: 0})
    end
  end

  describe "#sort_cards" do
    it "should sort the cards based on number" do
      cards = [
        {number: 2,     suit: :clubs},
        {number: 6,     suit: :hearts},
        {number: :ace,  suit: :clubs},
        {number: :jack, suit: :spades},
        {number: 3,     suit: :spades}
      ]
      sorted_cards = @probabilities.sort_cards(cards)
      expect(sorted_cards.map{|c| c[:number]}).to eq([:ace, :jack, 6, 3, 2])
    end
  end

  describe "#multiples" do
    it "should return how many of each number there are" do
      cards = [
        {number: 2,    suit: :clubs},
        {number: 2,    suit: :hearts},
        {number: :ace, suit: :clubs},
        {number: :ace, suit: :spades},
        {number: 2,    suit: :spades}
      ]
      multiples = @probabilities.multiples(cards)
      expect(multiples).to eq({2 => 3, :ace => 2})
    end
  end

  describe "#suits" do
    it "should return how many of each suit there are" do
      cards = [
        {number: 2,    suit: :clubs},
        {number: 2,    suit: :clubs},
        {number: :ace, suit: :spades},
        {number: :ace, suit: :spades},
        {number: 2,    suit: :spades}
      ]
      suits = @probabilities.suits(cards)
      expect(suits).to eq({spades: 3, clubs: 2})
    end
  end

  describe "#cards_contain_ace" do
    it "should return true if there is an ace" do
      cards = [
        {number: 2,    suit: :clubs},
        {number: 2,    suit: :clubs},
        {number: :ace, suit: :spades},
        {number: :ace, suit: :spades},
        {number: 2,    suit: :spades}
      ]
      expect(@probabilities.cards_contain_ace(cards)).to be true
    end
    it "should return false if there is not an ace" do
      cards = [
        {number: 2,    suit: :clubs},
        {number: 2,    suit: :clubs},
        {number: 9, suit: :spades},
        {number: 10, suit: :spades},
        {number: 2,    suit: :spades}
      ]
      expect(@probabilities.cards_contain_ace(cards)).to be false
    end
  end

  describe "#pairs" do
    it "should return one pair" do
      cards = [
        {number: 5, suit: :clubs},
        {number: 5, suit: :hearts}
      ]
      pairs = @probabilities.pairs(cards)
      expect(pairs.length).to eq (1)
      expect(pairs.map{|c| c[:pair]}).to eq([5])
    end
    it "should return two pairs" do
      cards = [
        {number: 5, suit: :clubs},
        {number: 5, suit: :hearts},
        {number: :ace, suit: :clubs},
        {number: :ace, suit: :hearts}
      ]
      pairs = @probabilities.pairs(cards)
      expect(pairs.length).to eq (2)
      expect(pairs.map{|c| c[:pair]}).to eq([:ace, 5])
    end
    it "should return the top two pairs only" do
      cards = [
        {number: 5, suit: :clubs},
        {number: 5, suit: :hearts},
        {number: :ace, suit: :clubs},
        {number: :ace, suit: :hearts},
        {number: :jack, suit: :clubs},
        {number: :jack, suit: :hearts}
      ]
      pairs = @probabilities.pairs(cards)
      expect(pairs.length).to eq (2)
      expect(pairs.map{|c| c[:pair]}).to eq([:ace, :jack])
    end
  end

  describe "#three_of_a_kind" do
    it "should return one three_of_a_kind" do
      cards = [
        {number: 5, suit: :clubs},
        {number: 5, suit: :diamonds},
        {number: 5, suit: :hearts}
      ]
      three_of_a_kind = @probabilities.three_of_a_kind(cards)
      expect(three_of_a_kind[:three_of_a_kind]).to eq(5)
    end
    it "should return only the top three_of_a_kind" do
      cards = [
        {number: 5, suit: :clubs},
        {number: 5, suit: :hearts},
        {number: 5, suit: :diamonds},
        {number: :ace, suit: :clubs},
        {number: :ace, suit: :diamonds},
        {number: :ace, suit: :hearts}
      ]
      three_of_a_kind = @probabilities.three_of_a_kind(cards)
      expect(three_of_a_kind[:three_of_a_kind]).to eq(:ace)
    end
  end

  describe "#four_of_a_kind" do
    it "should return one four_of_a_kind" do
      cards = [
        {number: 5, suit: :clubs},
        {number: 5, suit: :diamonds},
        {number: 5, suit: :spades},
        {number: 5, suit: :hearts}
      ]
      four_of_a_kind = @probabilities.four_of_a_kind(cards)
      expect(four_of_a_kind[:four_of_a_kind]).to eq (5)
    end
  end




# describe "#return_best_hand" do
  # context "it returns the correct hands" do
#     it "with a high card" do
#       cards_known = ["9h","3d", "ac", "7d", "2c", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("HC"=>"ac")
#     end
#     it "with a pair" do
#       cards_known = ["4h","4d", "ac", "7d", "2c", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands).to include("P"=>"4")
#       expect(returned_hands.length).to eq(1)
#     end
#     it "with two pair" do
#       cards_known = ["4h","4d", "ac", "ad", "2c", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("TP"=>"a's and 4's")
#     end
#     it "with three of a kind" do
#       cards_known = ["4h","4d", "4c", "7d", "2c", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("TOAK"=>"4")
#     end
#     it "with a full house" do
#       cards_known = ["4h","4d", "4c", "7d", "7c", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("FH"=>"4's over 7's")
#     end
#     it "with four of a kind" do
#       cards_known = ["4h","4d", "4c", "4s", "2c", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("FOAK"=>"4")
#     end
#     it "with a straight" do
#       cards_known = ["4h","3d", "ac", "7d", "2c", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("S"=>"a through 5")
#     end
#     it "with a flush" do
#       cards_known = ["4h","3h", "ah", "7h", "2c", "jh", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("F"=>"h")
#     end
#     it "with a straight flush" do
#       cards_known = ["4h","5h", "3h", "ah", "2h", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("SF"=>"ah through 5h")
#     end
#     it "with a royal flush" do
#       cards_known = ["10h","jh", "qh", "ah", "kh", "jd", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("RF"=>"10h through ah")
#     end
#     it "with consecutive non-straight cards" do
#       cards_known = ["10h","jh", "2d", "3c", "6s", "ad", "5d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("HC"=>"ad")
#     end
#     it "with more than 5 straight cards" do
#       cards_known = ["10h","jh", "qd", "9c", "8s", "7d", "6d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("S"=>"8 through q")
#     end
#     it "with 2 consecutive and 5 straight cards" do
#       cards_known = ["10h","jh", "qd", "9c", "8s", "2d", "3d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("S"=>"8 through q")
#     end
#     it "with a 10 in the straight" do
#       cards_known = ["10h","jh", "qd", "kc", "as", "2d", "3d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("S"=>"10 through a")
#     end
#     it "with a pair and a straight" do
#       cards_known = ["10h","jh", "qd", "kc", "as", "qh", "3d"]
#       returned_hands = @probabilities.return_best_hand(cards_known)
#       expect(returned_hands.length).to eq(1)
#       expect(returned_hands).to include("S"=>"10 through a")
#     end
#   end
# end

# describe "#return_possible_hands_based_on_community_cards" do
#   context "it returns the correct hands" do
#     before(:each) do
#       @probabilities = Probabilities.new
#     end

#     it "that are higher than the flop" do
#       cards_known = ["2d", "3d", "10h","jh", "qh", "kc", "as"]
#       expect(@probabilities.return_possible_hands_based_on_community_cards(cards_known)).to_not include("P"=>"k")
#       expect(@probabilities.return_possible_hands_based_on_community_cards(cards_known)).to include("RF"=>"10h through ah")
#     end

#     it "with a straight" do
#       cards_known = ["2d", "3d", "10h","jh", "qd", "kc", "as"]
#       expect(@probabilities.return_possible_hands_based_on_community_cards(cards_known)).to include("S"=>"10 through a")
#     end
#   end

# end
end
