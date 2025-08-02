module AssigningError
  class AlreadyUsedBySameUser < StandardError; end
  class AlreadyUsedOnOtherUser < StandardError; end
  class AlreadyUsedOnUser < StandardError; end
end