class Cleaner
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(picture_id)
    Picture.find(picture_id).destroy
  end
end
