class ConcertsController < ApplicationController
  before_action :set_concert, only: [:show, :attend, :show_interest]
  before_action :set_interest, only: [:look_for_individual,
                                      :look_for_group]

  def index
    @concerts = Concert.all

    @concerts.each do |concert|
      add_friend_and_attendees(concert)
    end
  end

  def show
    add_friend_and_attendees(@concert)
  end

  def attend
    attendees = @concert.attendees

    unless attendees.include? @current_user
      attendees << @current_user
      @concert.save
    end
  end

  # +1
  def look_for_individual
    unless @interest.nil?
      @interest.individual = true
      @interest.save
    end
  end

  # +8
  def look_for_group
    unless @interest.nil?
      @interest.group = true
      @interest.save
    end
  end

  # `Like` a person (+1)
  def show_interest
    @user = User.find(params[:profile_id])

    likes = @user.interests.find_by(concert_id: @concert.id).likes
    likes << @current_user
    likes.save
  end

  private

  def set_interest
    set_concert
    @interest = @current_user.interests.find_by(concert_id: @concert.id)
  end

  def set_concert
    @concert = Concert.find(params[:id])
  end

  def add_friend_and_attendees(concert)
    attendees = concert.attendees

    concert.num_attendees = attendees.count
    concert.friend_attendees =
      attendees.where(profile_id: @current_user.friends
                                               .pluck(:profile_id))
               .pluck_to_hash(:profile_id)

    concert.looking_for = attendees.collect do |attendee|
      attendee.interests.find_by(concert_id: @concert.id)
    end.pluck_to_hash(:individual, :group)
  end
end
