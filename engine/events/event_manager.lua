local EventManager = Class {
    init = function(self)
        self.subscribers = {} -- { “eventName”: {“system1”, “subscriber2”} }
        self.events = {} -- { system1: {event1, event2}, subscriber2: {event2, event3} }
    end
}

function EventManager:subscribe(subscriber, eventName)
    assert(type(eventName) == "string" and type(subscriber) == "string",
        "EventName and subscribers must be strings, got \'"..eventName.."\' and \'"..subscriber.."\'")

    if not self.subscribers[eventName] then
        self.subscribers[eventName] = {}
    end
    table.insert(self.subscribers[eventName], subscriber)
    if not self.events[subscriber] then
        self.events[subscriber] = {}
    end
end

function EventManager:unsubscribe(subscriber, eventName)
    if eventName and type(eventName) == "string" then
        for id, subscription in pairs(self.subscribers[eventName]) do
            if subscription == subscriber then
                self.subscribers[id] = nil
            end
        end
    end
    self.events[subscriber] = nil
end

function EventManager:send(eventName, event)
    if type(event) == "table" then event.name = eventName end
    for _, subscriber in pairs(self.subscribers[eventName]) do
        table.insert(self.events[subscriber], event)
    end
end

function EventManager:getEvents(subscriber)
    local events = self.events[subscriber]
    self.events[subscriber] = {}
    return events
end

return EventManager