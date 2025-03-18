# frozen_string_literal: true

# Called when accessioning / deposit is complete.
class DepositCompleteJob
  include Sneakers::Worker
  # This worker will connect to "h3.deposit_complete" queue
  # env is set to nil since by default the actual queue name would be
  # "h3.deposit_complete_development"

  # It is possible that this deposit event was initiated outside of h3. For
  # example, if the embargo was lifted, DSA would open and close a version. The
  # workflow message "end-accession" would end up here.  We must be able to handle
  # these messages in addition to those that result from depositing in h3.
  from_queue 'h3.deposit_complete', env: nil

  def work(msg_str)
    @msg_str = msg_str
    Honeybadger.context(druid:)
    Rails.logger.info("Deposit complete on #{druid}")

    object = Work.find_by(druid:) || Collection.find_by!(druid:)

    sync(object:)

    # This will ignore accessioning that was initiated outside of H3, since
    # the deposit state will not be accessioning.
    object.accession_complete! if object.accessioning?

    Turbo::StreamsChannel.broadcast_refresh_to object

    ack!
  end

  private

  def message
    JSON.parse(@msg_str)
  end

  def druid
    message.fetch('druid')
  end

  def sync(object:)
    if object.is_a? Work
      Synchronizers::Work.call(work: object, cocina_object:, raise: false)
    else
      Synchronizers::Collection.call(collection: object, cocina_object:)
    end
  end

  def cocina_object
    Sdr::Repository.find(druid:)
  end
end
