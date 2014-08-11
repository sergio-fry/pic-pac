class Cleaner
  include Sidekiq::Worker

  def perform(picture_id)
    Picture.where(picture_id).destroy
  end
end
