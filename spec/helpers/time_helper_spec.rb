# frozen_string_literal: true
require 'rails_helper'

describe TimeHelper do
  before do
    Timecop.freeze(Time.local(1990))
  end

  after do
    Timecop.return
  end

  subject { timeago(Time.zone.now) }

  it 'should return span with title, class and time in container' do
    expect(subject).to eq '<span title="1989-12-31T21:00:00Z" class="timeago-js">1989-12-31T21:00:00Z</span>'
  end
end
