require 'RMagick'
require 'open-uri'
require 'digest/sha1'

class Picture < ActiveRecord::Base
  def resize(width, height=nil)
    img = Magick::Image.read(src_url)[0]
    img.format = "JPEG"


    if height.present?
      logger.debug "cropping..."
      img.resize_to_fill!(width.to_i, height.to_i)
    else
      logger.debug "resizing..."
      img.resize_to_fit!(width.to_i, width.to_i)
    end


    logger.debug "upload..."
    bucket = AWS_STORE.directories.get ENV['S3_BUCKET_NAME']
    bucket.files.create(:key => "resized/#{id}/#{hash}.jpeg", :body => img.to_blob{ self.quality=50;  self.interlace = Magick::PlaneInterlace }, :public => true)

    self.dst_url = "http://s3-eu-west-1.amazonaws.com/pic-pac/resized/#{id}/#{hash}.jpeg"
    save!
  end

  private

  def hash
    Digest::SHA1.hexdigest(id.to_s + PicPac::Application.config.secret_key_base)[0..5]
  end
end
