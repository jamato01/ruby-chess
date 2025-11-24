module Chess
  class Move
    attr_reader :from, :to, :flags, :promotion

    def initialize(from:, to:, flags: 0, promotion: nil)
      @from = from
      @to = to
      @flags = flags
      @promotion = promotion
    end

    def is_promotion?
      !promotion.nil?
    end

    def capture?
      flags & CAPTURE != 0
    end
  end
end