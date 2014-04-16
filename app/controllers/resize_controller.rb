class ResizeController < ApplicationController
  def resize
    redirect_to params[:src]
  end
end
