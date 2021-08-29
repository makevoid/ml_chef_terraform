module Utils

  def chef_cli
    "chef-client --local-mode"
  end

  def recipes
    RECIPES
  end

  def recipes_vendor
    RECIPES_VENDOR
  end

  def set_host(host)
    STATE[:host] = host
  end

  def set_no_user(no_user)
    STATE[:no_user] = no_user
  end

  def current_host
    STATE[:host]
  end

  def no_user
    STATE[:no_user]
  end

end
