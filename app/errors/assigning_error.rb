module AssigningError
  class AlreadyUsedBySameUser < StandardError; end
  class AlreadyUsedOnOtherUser < StandardError; end
end