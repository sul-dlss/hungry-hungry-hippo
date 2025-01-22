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

  def work(msg)
    druid = parse_message(msg)
    Honeybadger.context(druid:)
    Rails.logger.info("Deposit complete on #{druid}")

    object = Work.find_by(druid:) || Collection.find_by!(druid:)
    object.accession_complete! if object.accessioning?

    ack!
  end

  def parse_message(msg)
    json = JSON.parse(msg)
    json.fetch('druid')
  end
end
