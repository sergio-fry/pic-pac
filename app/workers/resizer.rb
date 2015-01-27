class Resizer
  include Sidekiq::Worker
  sidekiq_options :queue => :high_priority, :retry => false

  def perform(picture_id, width, height)
    Picture.find(picture_id).resize(width, height)
  end
end
