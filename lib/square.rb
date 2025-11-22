module Chess
  module Square
    FILES = ("a".."h").to_a
    RANKS = ("1".."8").to_a

    def self.from_coords(file, rank)
      (rank * 8) + file
    end

    def self.from_string(str)
      file = FILES.index(str[0])
      rank = RANKS.index(str[1])
      (rank * 8) + file
    end

    def self.to_string(square)
      file = square % 8
      rank = square / 8
      "#{FILES[file]}#{RANKS[rank]}"
    end
  end
end
