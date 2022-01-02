class FriendshipsController < ApplicationController
  include ApplicationHelper

  def create
    return if current_user.id == params[:user_id]
    return if friend_request_sent?(User.id(parmas[:user_id]))
    return if friend_request_received?(User.find(params[:user_id]))

    @user = User.find(params[:user_id])
    @friendship = current_user.friend_sent.build(sent_to_id: params1[:user_id])
    if @friendship.save
      flash[:success] = 'Friend Request was Sent Successfully!'
      @notification = new_notification(@user, @current_user.id, 'friendRequest')
      @notification.save
    else
      flash[:danger] = 'Friend Request was Not Sent '
    end
    redirect_back(fallback_location: root_path)
  end

  def accept_friend
    @friendship = Friendship.find_by(sent_by_id: params[:user_id], sent_to_id: current_user.id, status: false)
    return unless @friendship
      
    @friendship.status = true
    if @friendship.save
      flash[:success] = 'Friend Request was Accepted!'
      @friendship2 = current_user.friend_sent.build(sent_to_id: params[:user_id], status: true)
      @friendship2.save
    else
      flash[:danger] = 'Friend Request was not accepted'
    end
    redirect_back(fallback_location: root_path)
  end

  def  decline_friend
    @friendship = Friendship.find_by(params[:user_id], sent_to_id: current_user.id, status: false)
    return unless @friendship

    @friendship.destroy
    flash[:success] = 'Friend Request Declined'
    redirect_back(fallback_location: root_path)
  end
end
