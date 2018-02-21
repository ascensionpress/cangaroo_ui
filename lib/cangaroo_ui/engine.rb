module CangarooUI
  class Engine < ::Rails::Engine
    isolate_namespace CangarooUI
  end
end
CangarooUi = CangarooUI

require 'will_paginate/railtie'
