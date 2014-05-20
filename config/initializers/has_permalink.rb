module HasPermalink

  module InstanceMethods
    # the gem returns permalink here and we do not want this for all links
    # so overriding and reseting back to self.id
    def to_param
      "#{self.id}"
    end
  end
end
