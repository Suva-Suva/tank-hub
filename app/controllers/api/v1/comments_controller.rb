class Api::V1::CommentsController < ApplicationController

  def index
    # Загружаем все комментарии, самые свежие — сверху
    @comments = Comment.order(created_at: :desc).limit(10)
    render json: @comments
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = User.first

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :post_id, :user_id)
  end
end