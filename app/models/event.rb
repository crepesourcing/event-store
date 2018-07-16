require "active_record"

# == Schema Information
#
# Table name: controller_requests
#
#  id           :integer    not null, primary key
#  uuid         :string     not null, unique
#  emitter      :string     not null
#  name         :string     not null
#  kind         :string     not null
#  timestamp    :datetime   not null
#  stored_at    :datetime   not null, default: STATEMENT_TIMESTAMP()
#  data         :jsonb      not null
#
class Event < ActiveRecord::Base

  def self.build_from_event(original_event)
    event           = Event.new
    event.uuid      = original_event.id
    event.emitter   = original_event.emitter
    event.name      = original_event.name
    event.timestamp = original_event.timestamp
    event.kind      = original_event.kind
    event.data      = original_event.data
    event
  end



end
