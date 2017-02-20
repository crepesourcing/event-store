class QueueService

  QUEUE_TRESHOLD      = ENV["REPLAY_TRESHOLD"]&.to_i || 200000
  CONSTRAINT_WILDCARD = "*"

  def initialize(logger, queue_name_for_threshold)
    @logger                   = logger
    @queue_name_for_threshold = queue_name_for_threshold
    @queue_repository         = Flu::QueueRepository.new(Flu.config)
    @logger.info("Queue Service initialized. Thresholds will be based on queue: #{@queue_name_for_threshold} with limit threshold of #{QUEUE_TRESHOLD}")
  end

  def wait_until_queue_is_not_overwhelmed
    threshold_overwhelmed = true
    while threshold_overwhelmed do
      queue                 = @queue_repository.find_queue(@queue_name_for_threshold)
      threshold_overwhelmed = queue.messages_ready + queue.messages_unacknowledged > QUEUE_TRESHOLD
      if threshold_overwhelmed
        sleep(30)
      end
    end
  end

  def find_constraints_from_bindings(queue_name)
    unless queue_name.nil?
      check_if_queue_exists!(queue_name)

      routing_keys = @queue_repository.find_bindings_for_queue(queue_name).map do |binding|
        binding["routing_key"]
      end - [queue_name]

      routing_keys.map do | routing_key |
        routing_key_to_constraint(routing_key)
      end
    else
      []
    end
  end

  def purge_all_queues
    queue_names = @queue_repository.find_all.map { |queue| queue["name"] }
    @logger.info("Purging all queues: #{queue_names}")
    queue_names.each do |queue_name|
      @queue_repository.purge_queue(queue_name)
    end
  end

  def delete_all_queues_expect(*queue_names)
    queue_names_to_keep   = queue_names || []
    queue_names_to_delete = @queue_repository.find_all.map { |queue| queue["name"] } - queue_names_to_keep
    queue_names_to_delete.each do |queue_name|
      @logger.info("Delete queue: #{queue_name}")
      @queue_repository.delete_queue(queue_name)
    end
  end

  private

  def routing_key_to_constraint(routing_key)
    parts                = routing_key.split(".")
    constraint           = {}
    constraint[:emitter] = parts[1] unless parts[1] == CONSTRAINT_WILDCARD
    constraint[:kind]    = parts[2] unless parts[2] == CONSTRAINT_WILDCARD
    constraint[:name]    = parts[3] unless parts[3] == CONSTRAINT_WILDCARD
    constraint
  end

  def check_if_queue_exists!(queue_name)
    queue_names = @queue_repository.find_all.map { |queue| queue["name"] }
    unless queue_names.include?(queue_name)
      raise "This queue (#{queue_name}) does not exist. Please choose in these queues: #{queue_names}"
    end
  end
end
