class ResizeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:run_delayed_jobs, :update_metrics, :delete_unused]

  def index
    @pictures = Picture.where("dst_url IS NOT NULL").order("created_at DESC").limit(30)
  end

  def resize
    transformtaion = "w=#{params[:w].to_i}"
    transformtaion += "h=#{params[:h].to_i}" if params[:h].present?

    @picture = Picture.find_or_create_by(:src_url => params[:src], :transformtaion => transformtaion)

    if @picture.dst_url.blank?
      @picture.delay.resize(params[:w], params[:h])
    end

    if @picture.dst_url
      @picture.update_attribute(:last_access_time, Time.now)
      expires_in(1.days, public: true) if Rails.env.production?
      redirect_to @picture.dst_url
    else
      redirect_to params[:src]
    end
  rescue Exception => e
    Rails.logger.error e

    redirect_to params[:src]
  end

  def delete_unused
    Picture.where(["last_access_time < ?", 30.days.ago]).each do |picture|
      picture.delay(:priority => 20).destroy
    end

    render :text => "OK"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def update_metrics
    SimpleMetric::Metric.add_data_point("Picture.count", Time.now, Picture.count)
    SimpleMetric::Metric.add_data_point("Picture.count(1.week)", Time.now, Picture.where(["last_access_time > ?", 1.week.ago]).count)
    SimpleMetric::Metric.add_data_point("Picture.count(2.weeks)", Time.now, Picture.where(["last_access_time > ?", 2.weeks.ago]).count)
    SimpleMetric::Metric.add_data_point("Picture.count(3.weeks)", Time.now, Picture.where(["last_access_time > ?", 3.weeks.ago]).count)
    render :text => "OK"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end

  def run_delayed_jobs
    t = Time.now

    threads = []

    worker = Delayed::Worker.new

    10.times do
      threads << Thread.new do
        loop do
          break if t < 40.seconds.ago
          jobs_done_count = begin
                              worker.work_off(1).try(:sum)
                            rescue StandardError => ex
                              logger.error ex.to_s
                              0
                            end

          break if jobs_done_count == 0
        end
      end
    end

    threads.each(&:join)

    render :text => "OK. Jobs left: #{Delayed::Job.count}"
  rescue Exception => $e
    render :text => "Error: #{$e}"
  end
end
