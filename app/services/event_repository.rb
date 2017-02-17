class EventRepository
  def initialize(logger)
    @logger = logger
    @logger.info("Event Repository initialized.")
  end

  def for_each_event(constraints, first_event_id, batch_size)
    query     = create_query(constraints, first_event_id)
    event_ids = ActiveRecord::Base.connection.execute(query).map { | result | result["id"].to_i }
    first_id  = event_ids.min
    last_id   = event_ids.max

    @logger.info("Replaying #{event_ids.size} events with ids [#{first_id}, #{last_id}}]...")
    event_ids.in_groups_of(batch_size, false).each do | ids |
      Event.order(:id).where(id: ids).each do | stored_event |
        print "\r"      unless stored_event.id == first_id
        print "Event: #{stored_event.id} / #{last_id}"
        yield(stored_event, first_id, last_id)
      end
    end
    @logger.info("Replaying events: done.")
  end

  private

  def constraints_to_clause(constraints)
    unless constraints.empty?
      constraints.select do | constraint |
        !constraint.empty?
      end.map do | constraint |
        constraint_to_condition(constraint)
      end.join(" OR ")
    else
      "true"
    end
  end

  def constraint_to_condition(constraint)
    if constraint.empty?
      "false"
    elsif constraint.size == 1
      "#{constraint.keys[0]}='#{constraint.values[0]}'"
    else
      columns = constraint.keys.join(",")
      values  = constraint.values.map {| value| "'#{value}'"}.join(",")
      "(#{columns})=(#{values})"
    end
  end

  def create_query(constraints, first_event_id)
    "SELECT id FROM events WHERE id >= #{first_event_id} AND (#{constraints_to_clause(constraints)}) ORDER BY id ASC"
  end
end
