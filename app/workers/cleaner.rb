class Cleaner
  include Sidekiq::Worker

  def perform(picture_id)
    Picture.find(picture_id).destroy
  end
end
