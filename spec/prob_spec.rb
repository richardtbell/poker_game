require 'spec_helper'

RSpec.describe Probabilities, "#return_hands" do
  context "it returns the correct hands" do
    before(:each) do
      @probabilities = Probabilities.new
    end

    it "with a high card" do
      cards_known = ["9h","3d", "ac", "7d", "2c", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("HC"=>"ac")
    end
    it "with a pair" do
      cards_known = ["4h","4d", "ac", "7d", "2c", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("P"=>"4")
    end
    it "with two pair" do
      cards_known = ["4h","4d", "ac", "ad", "2c", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("TP"=>"a's and 4's")
    end
    it "with three of a kind" do
      cards_known = ["4h","4d", "4c", "7d", "2c", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("TOAK"=>"4")
    end
    it "with a full house" do
      cards_known = ["4h","4d", "4c", "7d", "7c", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("FH"=>"4's over 7's")
    end
    it "with four of a kind" do
      cards_known = ["4h","4d", "4c", "4s", "2c", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("FOAK"=>"4")
    end
    it "with a straight" do
      cards_known = ["4h","3d", "ac", "7d", "2c", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("S"=>"a through 5")
    end
    it "with a flush" do
      cards_known = ["4h","3h", "ah", "7h", "2c", "jh", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("F"=>"h")
    end
    it "with a straight flush" do
      cards_known = ["4h","5h", "3h", "ah", "2h", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("SF"=>"ah through 5h")
    end
    it "with a royal flush" do
      cards_known = ["10h","jh", "qh", "ah", "kh", "jd", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("RF"=>"10h through ah")
    end
    it "with consecutive non-straight cards" do
      cards_known = ["10h","jh", "2d", "3c", "6s", "ad", "5d"]
      expect(@probabilities.return_hands(cards_known)).to include("HC"=>"ad")
    end
    it "with more than 5 straight cards" do
      cards_known = ["10h","jh", "qd", "9c", "8s", "7d", "6d"]
      expect(@probabilities.return_hands(cards_known)).to include("S"=>"8 through q")
    end
    it "with 2 consecutive and 5 straight cards" do
      cards_known = ["10h","jh", "qd", "9c", "8s", "2d", "3d"]
      expect(@probabilities.return_hands(cards_known)).to include("S"=>"8 through q")
    end
    it "with a 10 in the straight" do
      cards_known = ["10h","jh", "qd", "kc", "as", "2d", "3d"]
      expect(@probabilities.return_hands(cards_known)).to include("S"=>"10 through a")
    end

  end
end
