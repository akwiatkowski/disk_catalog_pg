require "jasper_helpers"

require "../services/tools/size_tools"

class ApplicationController < Amber::Controller::Base
  include JasperHelpers
  LAYOUT = "application.slang"
end
