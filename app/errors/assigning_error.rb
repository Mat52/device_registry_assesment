module AssigningError
  class AlreadyUsedBySameUser < StandardError; end
  class AlreadyUsedOnOtherUser < StandardError; end
  class AlreadyUsedOnUser < StandardError; end
  class AlreadyUnassigned < StandardError; end
  class Unauthorized < StandardError; end
end