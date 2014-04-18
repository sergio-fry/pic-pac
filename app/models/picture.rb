require 'RMagick'
require 'open-uri'
require 'digest/sha1'

class Picture < ActiveRecord::Base
  before_destroy :erase_file

  def resize(width, height=nil)
    width, height = width.to_i, height.try(:to_i)
    img = Magick::Image.read(src_url)[0]
    img.format = "JPEG"


    if height.present?
      logger.debug "cropping..."

      src_ratio = img.columns.to_f / img.rows.to_f
      target_ratio = width.to_f / height.to_f

      if target_ratio > src_ratio
        img.resize_to_fill!(img.columns, (img.rows.to_f/target_ratio.to_f).round)
      else
        img.resize_to_fill!((target_ratio*img.rows).round, img.rows)
      end

      img.resize_to_fill!(width, height)
    else
      logger.debug "resizing..."
      img.resize_to_fit!(width, width)
    end


    logger.debug "upload..."
    bucket = AWS_STORE.directories.get ENV['S3_BUCKET_NAME']
    bucket.files.create(:key => "resized/#{id}/#{hash}.jpeg", :body => img.to_blob{ self.quality=75;  self.interlace = Magick::PlaneInterlace }, :public => true)

    self.dst_url = "http://s3-eu-west-1.amazonaws.com/pic-pac/resized/#{id}/#{hash}.jpeg"
    save!
  end

  private

  def hash
    Digest::SHA1.hexdigest(id.to_s + PicPac::Application.config.secret_key_base)[0..5]
  end

  def erase_file
    bucket = AWS_STORE.directories.get ENV['S3_BUCKET_NAME']
    bucket.files.create(:key => "resized/#{id}/#{hash}.jpeg", :body => "removed", :public => true)
  end
end
