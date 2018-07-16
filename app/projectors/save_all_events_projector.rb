require_relative "../services/event_ignore_strategy"

class SaveAllEventsProjector < Happn::Projector

  def define_handlers
    on status: :new do |event|
      if EventIgnoreStrategy.should_ignore?(event)
        @logger.info("Event '#{persistent_event.name}' have been ignored")
      else
        persistent_event = Event.build_from_event(event)
        persistent_event.save!
        @logger.info("Event '#{persistent_event.name}' saved with id : #{persistent_event.id}")
      end
    end
  end
end
