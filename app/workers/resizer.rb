class Resizer
  include Sidekiq::Worker

  def perform(picture_id, width, height)
    Picture.find(picture_id).resize(width, height)
  end
end
