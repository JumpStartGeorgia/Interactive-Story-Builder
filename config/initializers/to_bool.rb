class String
  def to_bool
    if self =~ (/^(true|t|yes|y|1)$/i)
      return true 
    else
      return false
    end
  end
end
