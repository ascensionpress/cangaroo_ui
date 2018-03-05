require 'will_paginate/railtie'
require 'bootstrap-will_paginate'

module CangarooUI
  class Engine < ::Rails::Engine
    isolate_namespace CangarooUI
  end
end
CangarooUi = CangarooUI
