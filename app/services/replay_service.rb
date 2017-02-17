require_relative "event_repository"
require_relative "queue_service"

class ReplayService

  MAX_ATTEMPT = 5
  BATCH_SIZE  = 50000

  def self.build_to_replay_to_every_queue(first_event_id_to_replay)
    ReplayService.new(first_event_id_to_replay, nil, ENV["REPLAY_TRESHOLD_QUEUE_NAME"])
  end

  def self.build_to_replay_to_single_queue(first_event_id_to_replay, target_queue)
    ReplayService.new(first_event_id_to_replay, target_queue, target_queue, true)
  end

  def initialize(first_event_id_to_replay,
                 queue_to_bind,
                 queue_for_threshold,
                 to_single_queue=false)
    @logger              = Flu.config.logger
    @publisher           = Flu::EventPublisher.new(Flu.config)
    @publisher.connect
    @queue_to_bind       = queue_to_bind
    @first_event_id      = first_event_id_to_replay || 1
    @to_single_queue     = to_single_queue
    @queue_for_threshold = queue_for_threshold || queue_to_bind
    @queue_service       = QueueService.new(@logger, @queue_for_threshold)
    @event_repository    = EventRepository.new(@logger)
    @logger.info("ReplayService initialized with first_event_id=#{@first_event_id} and queue_to_bind=#{@queue_to_bind}")
  end

  def replay
    @queue_service.purge_all_queues
    if @to_single_queue && !@queue_to_bind.nil?
      @queue_service.delete_all_queues_expect(@queue_to_bind)
    end

    constraints                        = @queue_service.find_constraints_from_bindings(@queue_to_bind)
    event_count_before_threshold_check = BATCH_SIZE
    @event_repository.for_each_event(constraints, @first_event_id, BATCH_SIZE) do | stored_event |
      event           = Flu::Event.new(stored_event.uuid, stored_event.emitter, stored_event.kind, stored_event.name, stored_event.data)
      event.timestamp = stored_event.timestamp
      event.mark_as_replayed
      publish(event, stored_event.id)

      event_count_before_threshold_check -= 1
      if event_count_before_threshold_check == 0
        @queue_service.wait_until_queue_is_not_overwhelmed
        event_count_before_threshold_check = BATCH_SIZE
      end
    end
  end

  private

  def publish(event, stored_id, attempt=0)
    begin
      @publisher.publish(event, false)
    rescue => e
      if attempt > MAX_ATTEMPT
        logger.error("Publishing event with id=#{stored_id} failed", e)
        raise e
      else
        sleep(5)
        publish(event, stored_id, attempt + 1)
      end
    end
  end
end
