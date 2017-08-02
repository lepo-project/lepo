module RandomString
  extend ActiveSupport::Concern
  ALPHANUMS = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9].freeze

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def random_string(size)
    (1..size).map do
      ALPHANUMS.map(&:to_s)[rand(ALPHANUMS.size)]
    end.join
  end

  def ym_random_string(size)
    Time.now.strftime('%Y%m_' + random_string(size))
  end
end
